module ROM
  module DynamoDB
    module Commands
      class Update < ROM::Commands::Update
        adapter :dynamodb

        def execute(attributes)
          relation.to_a.collect { |tuple| with_tuple(tuple, attributes) }
        end

        def with_tuple(tuple, attributes)
          data = tuple.is_a?(Hash) ? tuple : tuple.to_h
          source.update(input[data], attributes.to_h)
        end
      end
    end
  end
end
