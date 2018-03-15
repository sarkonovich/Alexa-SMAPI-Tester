
class AlexaTester
  include OS
  attr_accessor :access_token, :refresh_token

  def initialize
    @access_token ||= read_tokens["access_token"]
    @refresh_token ||= read_tokens["refresh_token"]
    init if @refresh_token.nil?
  end
  
  def init
    url = "http://localhost:4567/retrieve_token"
    Thread.start {AlexaInit.run!}
    sleep (1)
    if OS.mac?
      system("open", url)
    elsif OS.windows?
      system("start", url)
    else
      puts "Please open your browser to #{url} to get access token"
    end
  end

  def merge_hashes(array)
    raise StandardError.new "Array is not an Array of Hashes" unless array.all? {|e| e.is_a? Hash}
    array.each_with_object({}) do |el, h|
      el.each do |k, v|
        if h[k].nil?
          h[k] = v
        else
          h[k] = Array.new([h[k]]) << v
          h[k] = h[k].flatten
        end
      end
    end
  end 

  private

  def smapi_post(url, body)
    HTTParty.post(url, body: body.to_json, headers: header)
  end

  def smapi_get(url)
    HTTParty.get(url, headers: header)
  end

  def read_tokens
    begin
      JSON.parse(File.read("#{CREDENTIALS}/.alexa_tester_tokens.json"))
    rescue
      "Token file not found"
    end
  end

  def header
    {"Content-Type"=>"application/x-www-form-urlencoded;charset=UTF-8", "Authorization"=>self.access_token}
  end

  # Modified by subclasses
  def url
    "https://api.amazonalexa.com/v1"
  end

  def refresh_access_token
    begin
      token = File.read("#{CREDENTIALS}/.alexa_tester_tokens.json")
      token = JSON.parse(token)["refresh_token"]
      secret = JSON.parse(File.read("#{CREDENTIALS}/.client_credentials"))["secret"]
      id = JSON.parse(File.read("#{CREDENTIALS}/.client_credentials"))["id"]
    rescue Errno::ENOENT
      raise "Couldn't find proper credentials. You need to re-initialize"
    end

    if token.nil? || secret.nil? || id.nil?
      puts "Couldn't find proper credentials. You need to re-initialize"
    end 

    uri = URI.parse("https://api.amazon.com/auth/o2/token")
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/x-www-form-urlencoded;charset=UTF-8"
    request.set_form_data(
      "client_id" => "#{id}",
      "client_secret" => "#{secret}",
      "grant_type" => "refresh_token",
      "redirect_uri" => "http://localhost:4567/callback",
      "refresh_token" => "#{token}",
    )

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    if response.code != "200" 
      raise "There was an error refreshing token" 
    end
    File.open("#{CREDENTIALS}/.alexa_tester_tokens.json","w") do |f|
      f.write(response.body)
    end
    puts "==========================================="
    puts "Success: Access Token Refreshed"
    puts "===========================================" 
    self.access_token = JSON.parse(response.body)["access_token"]
  end

  def ask_ask(string)
    Open3.capture3(string)
  end

  def handle_api_result(api)
    calling_method = caller[0].match(/get_simulation_results/).to_s
    tries ||= 0
    begin
      result = api.call
      raise AlexaTesterError::InvalidAuthToken      if result.message  == "Unauthorized"
      raise AlexaTesterError::SkillSimulationError  if result.code != 200
      raise AlexaTesterError::SimulationInProgress  if result["status"] == "IN_PROGRESS" && !calling_method.empty?
      result
    rescue AlexaTesterError => e
      error = result.parsed_response.is_a?(String) ? JSON.parse(result.parsed_response) : result.parsed_response
      puts "#{e}: #{result.code} #{error["message"]}"
      refresh_access_token if result.code == 401
      tries += 1
      if (tries) < 3
        puts "retrying..."
        sleep(tries + 1)
        retry
      else
        result
      end
    end
  end  
end
