module ROM
  module Dynamo
    module Commands
      class Delete < ROM::Commands::Delete
        adapter :dynamo

        def execute
          relation.collect(&method(:with_tuple))
        end

        def with_tuple(tuple)
          data = with(tuple).to_h
          source.delete(data).attributes
        end
      end
    end
  end
end
