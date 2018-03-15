module ReportOutput
  def format_report(invocation_phrase, result, output, defaults)
    id =  result["id"]
    if result["result"].keys.include?("error")
      return result["result"]["error"]
    end

    response_body = result["result"]["skillExecutionInfo"]["invocationResponse"]["body"]["response"] rescue nil
    request_body = result["result"]["skillExecutionInfo"]["invocationRequest"]["body"] rescue nil
    
    if response_body
      response_options = {
        "should_end_session"=>{"should_end_session?"=>response_body["shouldEndSession"]}, 
        "output_speech"=>{"output_speech"=>get_output_speech(response_body["outputSpeech"])}, 
        "reprompt_text"=>{"reprompt_text"=>response_body["reprompt"]["outputSpeech"]},
        "response_body"=>{"response"=>response_body}
      }
    end

    if request_body
      request_options = {
        "result_status"=>{"result_status"=>result["status"]}, 
        "session_attributes"=>{"session_attributes"=>result["result"]["skillExecutionInfo"]["invocationResponse"]["body"]["sessionAttributes"]}, 
        "response"=>{"response"=>result["result"]["skillExecutionInfo"]["invocationResponse"]},  
        "request"=>{"response"=>result["result"]["skillExecutionInfo"]["invocationRequest"]},
        "request_body"=>{"request"=>request_body},
        "session"=>{"session"=>request_body["session"]},
        "session_id"=>{"session_id"=>request_body["session"]["sessionId"]}
      }
    end

    general_options = {
      "result"=>{"result"=>result},
    }
    output_options = response_options.merge request_options if response_options
    output_options = output_options.merge general_options

    # only include valid option keys
    output = output & output_options.keys
    report_hash = []
    # populate the report
    unless defaults == false || (["response", "request"] & output).any?
      report_hash << { id => output_options["result_status"] }
      report_hash << { id => {"invocation_phrase" => invocation_phrase} }
    end
    output.each { |s| report_hash << { id => output_options[s]} }
    report_hash = merge_hashes(report_hash)
    report_hash
  end

  def get_output_speech(speech_hash)
    if speech_hash["type"] == "SSML"
      speech_hash["ssml"]
    else
      speech_hash["text"]
    end
  end
end
