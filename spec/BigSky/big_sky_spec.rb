
require_relative '../../lib/smapi_tester.rb'

SKILL_ID = "amzn1.echo-sdk-ams.app.06a72621-54b9-4767-a2e9-db3837fe9aae"
PHRASES = ["open big sky", "yes", "ask big sky if it will rain in three hours"]
BigSky = AlexaSimulator.new(SKILL_ID, PHRASES)

RSpec.describe BigSky do
  results = BigSky.test(output: "response")
  let(:response) { ResponseObject.new }
  context 'open big sky' do
    it 'keeps session open'  do
      expect(response.should_end_session(results[0])).to eq false
    end

    it 'returns session attributes'  do
      expect(response.session_attributes(results[0]).keys).to eq ["humidity_wind", "details_store"]
    end

    it 'gives current weather'  do
      expect(response.output_speech(results[0])).to include "Currently,"
    end
  end
end