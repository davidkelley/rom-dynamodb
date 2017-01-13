require 'rom'
require 'aws-sdk-core'
require 'deep_merge'

require 'rom/dynamo/dataset'
require 'rom/dynamo/gateway'
require 'rom/dynamo/commands'
require 'rom/dynamo/relation'

module ROM
  module Dynamo
  end
end

ROM.register_adapter(:dynamo, ROM::Dynamo)
