module ROM
  module Dynamo
    class Relation < ROM::Relation
      adapter :dynamo

      forward :restrict, :scan, :retrieve, :batch_get

      forward :create, :delete, :update

      def info
        dataset.information
      end

      # def count
      #   dataset.size
      # end
    end
  end
end
