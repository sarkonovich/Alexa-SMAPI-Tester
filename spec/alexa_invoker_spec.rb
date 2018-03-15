require 'spec_helper'
require 'smapi_tester'

RSpec.describe AlexaInvoker do

  before do
    allow_any_instance_of(AlexaSimulator).to receive(:read_tokens).and_return({"refresh_token"=>"my_refresh_token", "access_token"=>"my_access_token"})
    allow_any_instance_of(AlexaInvoker).to receive(:read_tokens).and_return({"refresh_token"=>"my_refresh_token", "access_token"=>"my_access_token"})
  end

  let(:request) { AlexaSimulator.new(SKILL_ID, "open magic eight ball").test(output: "request") }
  let(:invoker) { described_class.new(request) }
  
  describe '#url' do
    it 'generates the url to send an invocation request' do
      VCR.use_cassette 'model/invoker_url' do 
        expect(invoker.url).to eq "https://api.amazonalexa.com/v1/skills/#{SKILL_ID}/invocations"
      end
    end
  end

  describe '#invoke' do 
    it 'receives a JSON invocation request response' do
      VCR.use_cassette 'model/invoker_invoke' do
        response = invoker.invoke
        expect(response["skillExecutionInfo"]["invocationRequest"]["body"].keys).to eq ["version", "session", "context", "request"]
      end
    end
  end
end