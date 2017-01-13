FactoryGirl.define do
  factory :table, class: Hash do
    table_name { SecureRandom.uuid }

    transient do
      definitions({ id: :N })
      schema({ id: :HASH })
    end

    attribute_definitions do
      definitions.collect do |name, type|
        { attribute_name: name, attribute_type: type }
      end
    end

    key_schema do
      schema.collect do |name, type|
        { attribute_name: name, key_type: type }
      end
    end

    provisioned_throughput do
      {
        :read_capacity_units => 1,
        :write_capacity_units => 1,
      }
    end

    initialize_with { attributes }
  end
end
