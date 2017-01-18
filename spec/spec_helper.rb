require 'simplecov'
require 'coveralls'
Coveralls.wear!
SimpleCov.start

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require "securerandom"
require "transproc/all"
require "factory_girl"
require "faker"
require "rom/dynamodb"


Dir[Pathname(__FILE__).dirname.join('shared/*.rb').to_s].each { |f| require f }

Dir[Pathname(__FILE__).dirname.join('factories/*.rb').to_s].each { |f| require f }

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end
