$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require "securerandom"
require "factory_girl"
require "rom/dynamo"

Dir[Pathname(__FILE__).dirname.join('shared/*.rb').to_s].each { |f| require f }

Dir[Pathname(__FILE__).dirname.join('factories/*.rb').to_s].each { |f| require f }

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end
