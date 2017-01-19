module ROM
  module DynamoDB
    class Relation < ROM::Relation
      adapter :dynamodb

      # @!macro r.forward
      # Forwards the $1 operation to the underlying dataset.
      # @see DynamoDB::Dataset#$1
      forward :restrict

      # @!macro r.forward
      forward :scan

      # @!macro r.forward
      forward :retrieve

      # @!macro r.forward
      forward :batch_get

      # @!macro r.forward
      forward :equal

      # @!macro r.forward
      forward :index

      # @!macro r.forward
      forward :before

      # @!macro r.forward
      forward :after

      # @!macro r.forward
      forward :between

      # @!macro r.forward
      forward :select

      # @!macro r.forward
      forward :offset

      # @!macro r.forward
      forward :limit

      # @!macro r.forward
      foward :create

      # @!macro r.forward
      foward :delete

      # @!macro r.forward
      foward :update

      # @!macro r.forward
      foward :ascending

      # @!macro r.forward
      foward :descending

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

      # @see {https://docs.aws.amazon.com/sdkforruby/api/Aws/DynamoDB/Client.html#describe_table-instance_method}
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
