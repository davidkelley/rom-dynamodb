# ROM DynamoDB Adapter
 [![Gem Version](https://badge.fury.io/rb/rom-dynamodb.svg)](https://badge.fury.io/rb/rom-dynamodb) [![GitHub](https://img.shields.io/badge/github-davidkelley%2From--dynamo-blue.svg)](https://github.com/davidkelley/rom-dynamodb) [![Documentation](http://img.shields.io/badge/docs-rdoc.info-blue.svg)](http://www.rubydoc.info/github/davidkelley/rom-dynamodb) [![License](http://img.shields.io/badge/license-MIT-yellowgreen.svg)](#license)  [![Gitter](http://img.shields.io/badge/gitter-rom--rb-red.svg)](https://gitter.im/rom-rb/chat)

 [![Code Climate](https://codeclimate.com/github/davidkelley/rom-dynamodb/badges/gpa.svg)](https://codeclimate.com/github/davidkelley/rom-dynamodb) [![Coverage Status](https://coveralls.io/repos/github/davidkelley/rom-dynamodb/badge.svg?branch=master)](https://coveralls.io/github/davidkelley/rom-dynamodb?branch=master) [![Dependency Status](https://gemnasium.com/badges/github.com/davidkelley/rom-dynamodb.svg)](https://gemnasium.com/github.com/davidkelley/rom-dynamodb)
 [![Build Status](https://travis-ci.org/davidkelley/rom-dynamodb.svg?branch=master)](https://travis-ci.org/davidkelley/rom-dynamodb) [![Inline docs](http://inch-ci.org/github/davidkelley/rom-dynamodb.svg?branch=master)](http://inch-ci.org/github/davidkelley/rom-dynamodb)

---

This adapter uses [ROM (>= 2.0.0)](http://rom-rb.org/) to provide an easy-to-use, clean and understandable interface for [AWS DynamoDB](https://aws.amazon.com/documentation/dynamodb/).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rom-dynamodb'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rom-dynamodb

## Usage

The following container setup is for demonstration purposes only. You should follow the standard way of integrating ROM into your environment, as [documented here](http://rom-rb.org/learn/advanced/flat-style-setup/).

```ruby
require 'rom/dynamodb'

TABLE = "my-dynamodb-users-table"

# any other AWS::DynamoDB::Client options
credentials = { region: 'us-east-1' }

container = ROM.container(:dynamodb, credentials) do |rom|
  rom.relation(:users) do
    # Key Schema: id<Hash>
    dataset TABLE
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
update.where(id: user[:id]) { id == id }.call(name: "Mark")

relation.where(id: user[:id]) { id == id }.one! # => { id: 2, name: "Mark" }

# delete an existing user
delete = container.commands[:users][:delete]
expressions = { id: user[:id] }
filter = -> { id == id }
delete.where(expressions, &filter).call
```
---

#### Querying a composite key DynamoDB Table

```ruby
container = ROM.container(:dynamodb, credentials) do |rom|
  rom.relation(:logs) do
    # Key Schema: host<Hash>, timestamp<Range>
    dataset "my-logs-table"

    def by_host(ip)
      equal(:host, ip)
    end

    def after_timestamp(time)
      after(:timestamp, time)
    end

    def before_timestamp(time)
      before(:timestamp, time)
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

all = relation.by_host(host).after(0).to_a # => [{host: "192.168.0.1", ... }, ...]

all.size # => 20

before = relation.by_host(host).before(Time.now.to_f + 60 * 60).limit(1).to_a

before.size # => 1

before.first == logs.first # => true

offset = { host: host, timestamp: logs[-2][:timestamp] }

last = relation.by_host(host).descending.after(0).offset(offset).limit(1).one!

last == logs.last # => true
```
---

## Development

All development takes place inside [Docker Compose](). Run the following commands to get setup:

```
$ docker-compose pull
$ docker-compose build
```

You can then begin developing, running RSpec tests with the following command:

```
$ docker-compose run rom rspec [args...]
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/davidkelley/rom-dynamo. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
