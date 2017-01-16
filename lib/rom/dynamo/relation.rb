module ROM
  module Dynamo
    class Relation < ROM::Relation
      adapter :dynamo

      forward :restrict, :scan, :retrieve, :batch_get

      forward :create, :delete, :update

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

      def keys
        @schema ||= dataset.information.key_schema.collect { |s| s.attribute_name.downcase.to_sym }
      end
    end
  end
end
