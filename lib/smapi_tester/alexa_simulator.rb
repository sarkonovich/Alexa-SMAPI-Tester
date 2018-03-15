NO_REPORT = ["FAILED", "IN_PROGRESS"]

class AlexaSimulator < AlexaTester
  include ReportOutput

  attr_reader :access_token, :refresh_token
  attr_accessor :skill_id, :locale, :phrases, :ids

  def initialize(skill_id, locale="en-US", phrases)
    super()
    @skill_id = skill_id
    @locale = locale
    @phrases = phrases
    @ids = {}
  end

  def test(phrases: self.phrases, output: [], defaults: true)
    run_simulations(phrases)
    get_simulation_results(output: output, defaults: defaults)
  end

  # ask cli: ask api simulate-skill -t [request_string] -s [skill_id] -l [locale]
  def run_simulations(test_phrases = self.phrases)
    raise "No phrases specified" if test_phrases.nil?
    self.ids = {} if self.ids.any?
    test_phrases = test_phrases.class == String ? [test_phrases] : test_phrases
    test_phrases.each do |phrase|
      body =  {"input": {"content": phrase},"device": {"locale": self.locale}}
      p body
      api_call = lambda {smapi_post(url, body)}
      result = handle_api_result(api_call)
      if result["id"]
        id = result["id"]
        p id
        self.ids[id] = phrase
      end 
      sleep(4) if test_phrases.size > 1
    end
    puts "======================================================="
    puts "Completed #{ids.size} / #{(test_phrases.size)} request(s)"
    puts "======================================================="
    self.ids
  end
  
  # ask cli: ask api get-simulation -i [id] -s [skill_id]
  def get_simulation_results(id: nil, output: [], defaults: true, writer: false)
    raise "No simulations to retrieve" if self.ids.empty?
    report, output = [], [output].flatten
    ids = id.nil? ? self.ids : [id].flatten
    ids.each do |k,v|
      v = "invocation phrase not provides" if v.nil?
      
      url = url(k)
      api_call = lambda {smapi_get(url)}
      result = handle_api_result(api_call)
      if result.code != 200
        next   
      elsif NO_REPORT.include?(result.parsed_response["status"])
        report << result.parsed_response
        next
      end

      # calls ReportOutput module
      report << format_report(v, result, output, defaults)
    end
    successes = report.map { |s| s.values.join.include?("SUCCESSFUL") }.size
    failures = ids.size - successes
    puts "================================================================"
    puts "Retrieved #{report.size} / #{ids.size} simulation result(s)"
    puts "Successes: #{successes} / Failures: #{failures}"
    puts "================================================================"

    
    if writer == true
      File.open("results/#{self.skill_id}=#{DateTime.now.iso8601}.json", "w") do |f|
        f.write(report.to_json)
      end
    end
    report
  end

  def url(simulation_id = nil)
    super() + "/skills/#{self.skill_id}/simulations/#{simulation_id}"
  end
end