CREDENTIALS = File.dirname(__FILE__) + '/smapi_tester'

require 'json'
require 'open3'
require 'httparty'
require 'sinatra'

require_relative 'smapi_tester/which_os'
require_relative 'smapi_tester/report_output'
require_relative 'smapi_tester/alexa_tester_error'
require_relative 'smapi_tester/alexa_tester.rb'
require_relative 'smapi_tester/alexa_simulator.rb'
require_relative 'smapi_tester/alexa_init.rb'
require_relative 'smapi_tester/alexa_invoker.rb'


module SMAPITester
end
