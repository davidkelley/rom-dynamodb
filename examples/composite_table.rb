require 'rom/dynamodb'

TABLE = "my-dynamodb-users-table"

# any other Aws::DynamoDB::Client options
credentials = { region: 'us-east-1' }

container = ROM.container(:dynamodb, credentials) do |rom|
  rom.relation(:logs) do
    # Key Schema: host<Hash>, timestamp<Range>
    dataset "my-logs-table"

    def by_host(ip)
      where { host == ip }
    end

    def after_timestamp(time)
      where { timestamp > time }
    end

    def before_timestamp(time)
      where { timestamp < time }
    end
  end

  rom.commands(:logs) do
    define(:create) do
      KEYS = %w(host timestamp message)
      result :one
      input Functions[:accept_keys, KEYS]
    end
  end
end

num_of_logs = 20

host = "192.168.0.1"

logs = (1..num_of_logs).to_a.collect do |i|
  { host: host, timestamp: Time.now.to_f + (i * 60), message: "some message" }
end

# create fake logs
container.commands[:logs][:create].call(logs)

relation = container.relation(:logs)

relation.count == num_of_logs # => true

all = relation.where(ip: host) { host == ip }.after(0).to_a # => [{host: "192.168.0.1", ... }, ...]

all.size # => 20

before = relation.where(ip: host) { [host == ip, timestamp < (Time.now.to_f + 60 * 60)] }.limit(1).to_a

before.size # => 1

before.first == logs.first # => true

offset = { ip: host, timestamp: logs[-2][:timestamp] }

last = relation.where(ip: host) { ip == host }.descending.after(0).offset(offset).limit(1).one!

last == logs.last # => true
