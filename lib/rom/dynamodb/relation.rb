module ROM
  module DynamoDB
    class Relation < ROM::Relation
      adapter :dynamodb

      # @!macro [attach] r.forward
      # Performs a $1 action on the relation. In most cases, these operations
      # can be chained to build up larger queries to perform.
      # @note This method forwards the $1 operation to the underlying dataset.
      # @see DynamoDB::Dataset#$1
      forward :restrict

      forward :scan

      forward :retrieve

      forward :batch_get

      forward :equal

      forward :index

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
