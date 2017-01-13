$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require "rom/dynamo"

Dir[Pathname(__FILE__).dirname.join('shared/*.rb').to_s].each { |f| require f }
