module ROM
  module Dynamo
    module Commands
      class Delete < ROM::Commands::Delete
        adapter :dynamo

        def execute
          relation.to_a.collect(&method(:with_tuple))
        end

        def with_tuple(tuple)
          data = tuple.is_a?(Hash) ? tuple : tuple.to_h
          source.delete(input[data])
        end
      end
    end
  end
end
