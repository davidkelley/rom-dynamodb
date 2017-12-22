unless ENV['TRAVIS']
  require 'simplecov'
  SimpleCov.start
end

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require "securerandom"
require "transproc/all"
require "factory_bot"
require "faker"
require "rom/dynamodb"


Dir[Pathname(__FILE__).dirname.join('shared/*.rb').to_s].each { |f| require f }

Dir[Pathname(__FILE__).dirname.join('factories/*.rb').to_s].each { |f| require f }

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end
