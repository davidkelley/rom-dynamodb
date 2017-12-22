require 'rom/dynamodb'

TABLE = "my-dynamodb-users-table"

# any other Aws::DynamoDB::Client options
credentials = { region: 'us-east-1' }

container = ROM.container(:dynamodb, credentials) do |rom|
  rom.relations[:users] do
    # Key Schema: id<Hash>
    dataset TABLE

    def by_id(val)
      where { id == val }
    end
  end

  rom.commands(:users) do
    FILTER = Functions[:symbolize_keys] >> Functions[:accept_keys, [:id]]

    define(:create) do
      KEYS = %w(id name)
      result :one
      input Functions[:accept_keys, KEYS]
    end

    define(:delete) do
      result :one
      input FILTER
    end

    define(:update) do
      result :one
      input FILTER
    end
  end
end

relation = container.relation(:users)

relation.count # => 1234

relation.where { id == 1 }.one! # => { id: 1, name: "David" }

relation.info # => <Hash> DynamoDB Table Information

relation.status # => :active

# create a new user
create = container.commands[:users][:create]
user = create.call({ id: 2, name: "James" })

# update an existing user
update = container.commands[:users][:update]
update.by_id(user[:id]).call(name: "Mark")

relation.where(id: user[:id]) { id == id }.one! # => { id: 2, name: "Mark" }

# delete an existing user
delete = container.commands[:users][:delete]
delete.by_id(user[:id]).call
