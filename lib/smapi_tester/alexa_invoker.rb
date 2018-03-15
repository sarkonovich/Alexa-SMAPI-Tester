class AlexaInvoker < AlexaTester

  attr_reader :access_token, :refresh_token, :locale, :end_point
  attr_accessor :request

  def initialize(locale="en-US", end_point = "NA", request)
    super()
    @locale = locale
    @end_point = end_point
    @request = get_request_body(request)
  end
   
  # ask cli: `ask api invoke-skill -e \"#{end_point}\" -s \"#{skill_id}\" -j '#{json}'`
  def invoke(request = self.request)
    api_call = lambda {smapi_post(url, prepare(request))}
    result = handle_api_result(api_call)
    result["result"]
  end

  
  def get_request_body(request)
    request = request.first if request.is_a?(Array)
    request.each_pair { |k,v|
     if k == "body"
      @found = v
     elsif v.is_a?(Hash)
       get_request_body(v)
     else
      next
     end 
     } 
     @found 
  end

  def prepare(request)
    request = request.first if request.is_a?(Array)
    request = {
        "endpointRegion" => "NA",
        "skillRequest" => {
        "body" => request
      }
    }
  end

  def skill_id
    id = JSON.parse(self.request.to_json)
    id["session"]["application"]["applicationId"]
  end

  def url
    super() + "/skills/#{self.skill_id}/invocations"
  end
end