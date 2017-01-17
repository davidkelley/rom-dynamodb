require 'rom'
require 'aws-sdk-core'
require 'deep_merge'

require 'rom/dynamodb/functions'
require 'rom/dynamodb/dataset'
require 'rom/dynamodb/gateway'
require 'rom/dynamodb/commands'
require 'rom/dynamodb/relation'

module ROM
  module DynamoDB
  end
end

ROM.register_adapter(:dynamodb, ROM::DynamoDB)
