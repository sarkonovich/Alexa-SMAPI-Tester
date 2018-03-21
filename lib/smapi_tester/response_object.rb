require 'ostruct'


class ResponseObject

  attr_accessor :response

  def initialize(simulator_response)
    @response = to_ostruct(simulator_response)
  end

  def request_body(array_item)  
    get_body(array_item).each { |k|
      if k.to_h.keys.first == :result
        return k.result.result.skillExecutionInfo.invocationRequest.body
      end
    }
  end

  def response_body(array_item)  
    get_body(array_item).each { |k|
      if k.to_h.keys.first == :result
        return k.result.result.skillExecutionInfo.invocationResponse.body
      end
    }
  end

  private

  def get_body(array_item)
    begin
      root = self.response[array_item].send(self.response[array_item].to_h.keys.first)
      if root.is_a? OpenStruct
        raise "Result JSON not provided. Use JSON returned by #get_simulation_results(output: 'result')"
      else
        root
      end
    rescue TypeError
      raise "Improper JSON provided "
    end
  end

  def to_ostruct(array_or_hash)
    if array_or_hash.is_a? Hash
      root = OpenStruct.new(array_or_hash)
      array_or_hash.each_with_object(root) do |(k,v), o|
        if v.is_a? HTTParty::Response
          v = v.parsed_response
        end
        o.send("#{k}=", to_ostruct(v))
      end
      root
    elsif array_or_hash.is_a? Array
      array_or_hash.map do |v|
        to_ostruct(v)
      end
    else
      array_or_hash
    end
  end
end


