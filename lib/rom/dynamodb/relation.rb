module ROM
  module DynamoDB
    class Relation < ROM::Relation
      adapter :dynamodb

      # retrieval
      forward :restrict, :scan, :retrieve, :batch_get, :equal, :index,
              :before, :after, :between, :select, :offset, :limit

      # operations
      forward :create, :delete, :update

      # storing
      forward :ascending, :descending

      # def initialize(*r)
      #   super *r
      #   puts schema.inspect
      # end

      def info
        dataset.information
      end

      def count
        dataset.information.item_count
      end

      def status
        dataset.information.table_status.downcase.to_sym
      rescue
        :unknown
      end
    end
  end
end
