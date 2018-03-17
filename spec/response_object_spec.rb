require 'spec_helper'
require 'smapi_tester'

# ResponseObject is a small class with some convenience methods for handling the response json.
RSpec.describe ResponseObject do
  before do
    allow_any_instance_of(AlexaSimulator).to receive(:read_tokens).and_return({"refresh_token"=>"my_refresh_token", "access_token"=>"my_access_token"})
  end
  
  subject(:response)  { ResponseObject.new }

  context 'when given the response json' do
    results = AlexaSimulator.new(SKILL_ID, PHRASE).test(output: "response")
    
    VCR.use_cassette 'model/response_object' do
      it 'returns output speech' do
        expect(response.output_speech(results[0])).to eq  "I'm ready to tell your future. Ask me any yes no question."
      end
    end 

     VCR.use_cassette 'model/response_object' do
      it 'returns session attributes' do
        expect(response.session_attributes(results[0]).empty?).to eq true
      end
    end 

     VCR.use_cassette 'model/response_object' do
      it 'returns whether the intent should end session' do
        expect(response.should_end_session(results[0])).to eq false
      end
    end 
  end
end 