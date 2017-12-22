FactoryBot.define do
  factory :table, class: Hash do
    table_name { SecureRandom.uuid }

    transient do
      definitions({ id: :S })

      schema({ id: :HASH })

      global([])

      local([])
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

    global_secondary_indexes do
      global.collect do |index, schema|
        {
          index_name: index,
          key_schema: schema.collect { |n, t| { attribute_name: n, key_type: t } },
          projection: {
            projection_type: "ALL"
          },
          provisioned_throughput: {
            read_capacity_units: 1,
            write_capacity_units: 1
          }
        }
      end unless global.empty?
    end

    local_secondary_indexes do
      local.collect do |index, schema|
        {
          index_name: index,
          key_schema: schema.collect { |n, t| { attribute_name: n, key_type: t } },
          projection: {
            projection_type: "ALL"
          },
          provisioned_throughput: {
            read_capacity_units: 1,
            write_capacity_units: 1
          }
        }
      end unless local.empty?
    end

    initialize_with { attributes }
  end
end
