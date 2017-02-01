module ROM
  module DynamoDB
    # Extending the relation class allows you to build in custom queries
    # that are often repeated throughout your code base, or those which need to be
    # tested in isolation.
    #
    # Below is a guided example for creating, updating, deleting and querying
    # information for a simple `User` table that consists of an `:id` key in the
    # form of a hash.
    #
    # {include:file:examples/simple_table.rb}
    #
    # The additional example below covers the same options but using a `Log`
    # table that contains a composite key, made up of `:host` and `:timestamp`,
    # which form the hash and range parts of the key, respectively.
    #
    # {include:file:examples/composite_table.rb}
    class Relation < ROM::Relation
      adapter :dynamodb

      # @!macro [attach] dm.forward
      # Performs a $0 $1 action on the relation. In most cases, these operations
      # can be chained to build up larger queries to perform.
      #
      # @note This method forwards the $1 operation to the underlying dataset.
      # 
      # @see DynamoDB::Dataset#$1
      forward :restrict

      forward :scan

      forward :retrieve

      forward :batch_get

      forward :equal

      forward :index

      forward :where

      forward :before

      forward :after

      forward :between

      forward :select

      forward :offset

      forward :limit

      forward :create

      forward :delete

      forward :update

      forward :ascending

      forward :descending

      # Retrieve a single record, providing a hash key name and the ID to
      # fetch.
      #
      # @note This is a very simple helper allowing you to easily retrieve
      #   singular records using a hash key lookup.
      #
      # @param key [Symbol] the hash key name to fetch on
      # @param id [String, Fixnum] an accepted data format for DynamoDB to lookup on
      # @return [Hash] a single object retrieved from DynamoDB
      def fetch(key, id)
        retrieve(key, id).one!
      end

      # @see https://docs.aws.amazon.com/sdkforruby/api/Aws/DynamoDB/Client.html#describe_table-instance_method
      # @return [Hash] AWS SDK payload of table information
      def info
        dataset.information
      end

      # @return [Fixnum] current total item count for the associated DynamoDB table
      def count
        dataset.information.item_count
      end

      # @return [Symbol] current status of the DynamoDB table
      def status
        dataset.information.table_status.downcase.to_sym
      rescue
        :unknown
      end
    end
  end
end
