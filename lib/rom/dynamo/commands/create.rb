module ROM
  module Dynamo
    module Commands
      class Create < ROM::Commands::Create
        adapter :dynamo

        def execute(tuples)
          tuples = tuples.is_a? Array ? tuples : [tuples]
          tuples.collect(&method(:with_tuple))
        end

        def with_tuple(tuple)
          data = with(tuple).to_h
          source.insert(data).attributes
        end
      end
    end
  end
end
