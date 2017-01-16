module ROM
  module Dynamo
    module Commands
      class Update < ROM::Commands::Update
        adapter :dynamo

        def execute(attributes)
          relation.to_a.collect do |tuple|
            with_tuple(tuple, attributes)
          end
        end

        def with_tuple(tuple, attributes)
          relation.update(key(tuple), attributes.to_h)
        end
      end
    end
  end
end
