require 'spec_helper'
require 'smapi_tester'

SKILL_ID = "amzn1.echo-sdk-ams.app.dd0a8464-ce80-49f8-ad10-d506259dd99c"
PHRASE = "open Magic EightBall"
PHRASES = ["open Magic EightBall", "will I be rich"]


RSpec.describe AlexaSimulator do
  before do
    allow_any_instance_of(AlexaSimulator).to receive(:read_tokens).and_return({"refresh_token"=>"my_refresh_token", "access_token"=>"my_access_token"})
  end
  
  subject(:simulator) { AlexaSimulator.new(SKILL_ID, PHRASES) }
  
  describe "#new" do
    it 'initializes with a given skill id' do
      expect(simulator.skill_id).to eq SKILL_ID
    end

    it 'has a default locale' do
      expect(simulator.locale).to eq "en-US"
    end

    it 'can be assigned a locale' do
      simulator = AlexaSimulator.new(SKILL_ID, "en-GB", PHRASE)
      expect(simulator.locale).to eq "en-GB"
    end

    it 'generates the url to post simulation requests' do
      url = "https://api.amazonalexa.com/v1/skills/#{SKILL_ID}/simulations/"
      expect(simulator.url).to eq url
    end 
  end

  describe '#run_simulations' do
    it 'stores a hash of invocation phrases and simulation ids' do
      VCR.use_cassette 'model/simulator_with_one_phrase' do
        ids = simulator.run_simulations
        expect(ids.class).to eq Hash
        expect(ids.any?).to eq true
      end
    end

    context 'given an array of phrases as an argument' do
      it 'receives hash with multiple simulation ids' do
        VCR.use_cassette 'model/simulator_with_two_phrases' do
          ids = simulator.run_simulations(PHRASES)
          expect(ids.class).to eq Hash
          expect(ids.size).to be > 1
        end
      end
    end
  end

  describe '#get_simulation_results' do
    it 'generates the url to get simulation results' do
      VCR.use_cassette('model/get_simulation_results_generate_url', :match_requests_on => [:method, :ignore_sim_id]) do
        simulator.run_simulations
        simulator.ids.each { |id|
          expect(simulator.send :url, "#{id[1]}").to eq simulator.url + "#{id[1]}"
        }
      end
    end

    context 'when no options are provided' do 
      it 'returns simulation results in an array of hashes' do
        VCR.use_cassette('model/get_simulation_results_returns_array', :match_requests_on => [:method, :ignore_sim_id]) do 
          simulator.run_simulations
          results = simulator.get_simulation_results
          expect(results.class).to eq Array
          expect(results.select { |result| result.is_a? Hash }.size).to eq PHRASES.size
        end
      end

      it 'provides simulation status' do
        VCR.use_cassette('model/get_simulation_results_status_output', :match_requests_on => [:method, :ignore_sim_id]) do
          simulator.run_simulations
          results = simulator.get_simulation_results
          results.each do |result|
            expect(result.values.flatten.first["result_status"]).to match (/SUCCESSFUL|FAILED|FAILURE/)
          end
        end
      end
    end

    context 'when output option "request" is provided' do
      it 'the hashes include request information' do
        VCR.use_cassette('model/get_simulation_results_request_output', :match_requests_on => [:method, :ignore_sim_id]) do
          simulator.run_simulations
          results = simulator.get_simulation_results(output: "request")
          simulation_id = results.first.keys.first
          expect(results.first[simulation_id]["response"]["body"]["request"].keys).to eq ["type", "requestId", "timestamp", "locale"]
        end
      end
    end

    context 'when output option "response" is provided' do
      it 'the hashes include response information' do
        VCR.use_cassette('model/get_simulation_results_response_output', :match_requests_on => [:method, :ignore_sim_id]) do
          simulator.run_simulations
          results = simulator.get_simulation_results(output: "response")
          simulation_id = results.first.keys.first
          expect(results.first[simulation_id]["response"]["body"].keys).to eq ["version", "response", "sessionAttributes"]
        end
      end
    end

    context 'when output option "write" is provided' do
      it 'the response is written to a file' do
        VCR.use_cassette('model/get_simulation_results_write_output', :match_requests_on => [:method, :ignore_sim_id]) do
          allow_any_instance_of(AlexaSimulator).to receive(:write_report).and_return("report content")
          simulator.run_simulations
          results = simulator.get_simulation_results(write: true)
          expect(simulator).to have_received(:write_report) do |result|
            expect(result).to eq results
          end
        end
      end
    end
  end
end