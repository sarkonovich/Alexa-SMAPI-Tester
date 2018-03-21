require 'spec_helper'
require 'smapi_tester'

SKILL_ID = "amzn1.echo-sdk-ams.app.dd0a8464-ce80-49f8-ad10-d506259dd99c"
PHRASE = "open magic eight ball"


# ResponseObject is a small class with some convenience methods for handling the response json.
RSpec.describe ResponseObject do
  before do
    allow_any_instance_of(AlexaSimulator).to receive(:read_tokens).and_return({"refresh_token"=>"my_refresh_token", "access_token"=>"my_access_token"})
  end
  

  context 'when given the response json' do
    results = AlexaSimulator.new(SKILL_ID, PHRASE).test(output: "result")
    subject(:simulation)  { ResponseObject.new(results) }
    
    VCR.use_cassette 'model/response_object' do
      it 'returns output speech' do
        expect(simulation.response_body(0).response.outputSpeech.text).to eq  "I'm ready to tell your future. Ask me any yes no question."
      end
    end 

     VCR.use_cassette 'model/response_object' do
      it 'returns session attributes' do
        expect(simulation.response_body(0).sessionAttributes.to_h.class).to eq Hash
      end
    end 

     VCR.use_cassette 'model/response_object' do
      it 'returns whether the intent should end session' do
        expect(simulation.response_body(0).response.shouldEndSession).to eq false
      end
    end 
  end
end 