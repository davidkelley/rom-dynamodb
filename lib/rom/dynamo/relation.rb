module ROM
  module Dynamo
    class Relation < ROM::Relation
      adapter :dynamo

      forward :restrict, :scan, :retrieve, :batch_get, :equal,
              :before, :after, :between, :select, :offset, :limit

      forward :create, :delete, :update

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
