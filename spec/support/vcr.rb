# spec/support/vcr.rb
require 'vcr'
VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures'
  c.hook_into :webmock
  c.allow_http_connections_when_no_cassette = true
  
  c.filter_sensitive_data('<ACCESS_TOKEN>') do |interaction|
    interaction.request.headers["Authorization"].first rescue nil
  end

  c.filter_sensitive_data('<ACCESS_TOKEN>') do |interaction|
    JSON.parse(interaction.response.body)["result"]["skillExecutionInfo"]["invocationRequest"]["body"]["session"]["user"]["accessToken"] rescue nil
    JSON.parse(interaction.response.body)["result"]["skillExecutionInfo"]["invocationRequest"]["body"]["context"]["System"]["user"]["accessToken"] rescue nil
  end
  
  c.filter_sensitive_data('<CONSENT_TOKEN>') do |interaction|  
    JSON.parse(interaction.response.body)["result"]["skillExecutionInfo"]["invocationRequest"]["body"]["session"]["user"]["permissions"]["consentToken"] rescue nil
  end

  c.filter_sensitive_data('<API_ACCESS_TOKEN>') do |interaction|  
    JSON.parse(interaction.response.body)["result"]["skillExecutionInfo"]["invocationRequest"]["body"]["context"]["System"]["apiAccessToken"] rescue nil
  end

  c.register_request_matcher :ignore_sim_id do |request1, request2|
    request1.uri.rpartition('/').first == request2.uri.rpartition('/').first
  end

  c.configure_rspec_metadata!
end