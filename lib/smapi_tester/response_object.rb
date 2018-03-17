class ResponseObject
  def should_end_session(result)
    prepared(result)["response"]["shouldEndSession"]
  end

  def session_attributes(result)
    prepared(result)["sessionAttributes"]
  end

  def output_speech(result)
    speech_hash = prepared(result)["response"]["outputSpeech"]
    if speech_hash["type"] == "SSML"
      speech_hash["ssml"]
    else
      speech_hash["text"]
    end
  end

  def prepared(result)
    result.values.first["response"]["body"]
  end
end


