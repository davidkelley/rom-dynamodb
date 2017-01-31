require "rom/dynamodb/dataset/where_clause"

module ROM
  module DynamoDB
    class Dataset
      # @!macro rom.dynamodb.dataset.chain_note
      # @note This method can be chained with other relational methods.

      # @!macro rom.dynamodb.dataset.order_note
      # @note Items with the same partition key value are stored in sorted
      #   order by sort key. If the sort key data type is Number, the results
      #   are stored in numeric order. For type String, the results are stored
      #   in order of ASCII character code values. For type Binary, DynamoDB
      #   treats each byte of the binary data as unsigned.

      # @!macro rom.dynamodb.dataset.series_note
      # @note Whilst the naming and parameters of this method indicate a
      #   time-series based operation, DynamoDB can perform a range query
      #   for any orderable data.

      # @attr_reader [String] name the full name of the DynamoDB Table to query.

      # @attr_reader [Symbol] operation the operation to perform on DynamoDB.

      # @attr_reader [Hash] config the configuration to apply to the underlying
      #   DynamoDB client.

      attr_reader :name, :operation, :config

      # @attr [Array<Hash>] queries the array of query sets to merge and use
      #   to query DynamoDB.

      #   This array of hashes is built up by chaining the
      #   relational methods together and when the query is finally executed,
      #   all the hashes in this array are merged and send to the underlying
      #   DynamoDB client.

      attr_accessor :queries

      def initialize(name:, operation: :query, config: {}, queries: [])
        @name = name
        @operation = operation
        @config = config
        @queries = queries
      end

      # The name of an index to query. This index can be any local secondary
      # index or global secondary index on the table.
      #
      # @!macro rom.dynamodb.dataset.chain_note
      #
      # @param name [String] the name of the index to query.
      #
      # @return [self] the {Dataset} object the method was performed on.
      def index(name)
        restrict(index_name: name)
      end

      # Performs a traversal of the index in ascending order on the range key.
      # DynamoDB will return the results in the order in which they
      # have been stored.
      #
      # @note This is the default behaviour.
      #
      # @!macro rom.dynamodb.dataset.chain_note
      # @!macro rom.dynamodb.dataset.order_note
      #
      # @return [self] the {Dataset} object the method was performed on.
      def ascending
        restrict(scan_index_forward: true)
      end

      # Performs a traversal of the index in descending order on the range key.
      # DynamoDB reads the results in reverse order by sort key value, and
      # then returns the results to the client.
      #
      # @note This is the default behaviour.
      #
      # @!macro rom.dynamodb.dataset.chain_note
      # @!macro rom.dynamodb.dataset.order_note
      #
      # @return [self] the {Dataset} object the method was performed on.
      def descending
        restrict(scan_index_forward: false)
      end

      # Limits the number of results returned by the query or scan operation.
      #
      # The maximum number of items to evaluate (not necessarily the number of
      # matching items). If DynamoDB processes the number of items up to the
      # limit while processing the results, it stops the operation and returns
      # the matching values up to that point.
      #
      # If there are more matches to be returned, the {#last_evaluated_key}
      #
      # @!macro rom.dynamodb.dataset.chain_note
      #
      # @return [self] the {Dataset} object the method was performed on.
      def limit(num = nil)
        append { { limit: num } unless num.nil? }
      end

      # The composite key of the first item that the resulting query will
      # evaluate. Use this method if you have a populated {#last_evaluated_key}.
      #
      # @!macro rom.dynamodb.dataset.chain_note
      #
      # @note When applying an offset, it must include the same composite key of
      #   which the index you are querying is composed from. Therefore, if your
      #   index has both a hash and range key, the key you provide must also have
      #   these.
      #
      # @param key [Hash] the composite offset key matching the queryable index.
      #
      # @return [self] the {Dataset} object the method was performed on.
      def offset(key)
        append { { exclusive_start_key: key } unless key.nil? }
      end

      # Selects one or more keys to retrieve from the table.
      #
      # These keys can include scalars, sets, or elements of a JSON
      # document.
      #
      # @!macro rom.dynamodb.dataset.chain_note
      #
      # @param keys [Array<String>] an array of string expressions to apply
      #   to the query
      #
      # @return [self] the {Dataset} object the method was performed on.
      def select(keys)
        restrict(projection_expression: keys.collect(&:to_s).join(","))
      end

      # Restricts keys within a composite key, by values using a specific operand.
      #
      # You can compose where clauses using compartive operators from inside
      # a block, allowing a greater level of flexibility.
      #
      # Multiple where clauses can be chained, or multiple predicates defined
      # inside an array within a single clause. See the examples below.
      #
      # @!macro rom.dynamodb.dataset.chain_note
      #
      # @note The following operands are supported, :>=, :>, :<, :<=, :== and :between
      #
      # @example Given Table[id<Hash>,legs<Range>]
      #   animals = relation.where { [id == "mammal", legs > 0] }
      #   animals #=> [{id: "mammal", legs: 2, name: "Human"}, ...]
      #
      # @example Using a value mapping hash
      #   keys = { type: "mammal", min_legs: 2 }
      #   animals = relation.where(keys) { [id == type, legs > min_legs] }
      #   animals #=> [{id: "mammal", legs: 2, name: "Elephant"}, ...]
      #
      # @example Matching by exact value
      #   keys = { type: "mammal" }
      #   animals = relation.where(keys) { id == type }
      #   animals #=> [{id: "mammal", legs: 2, name: "Elephant"}, ...]
      #
      # @example Between two values
      #
      # @example Matching with begins_with
      #
      def where(maps = {}, &block)
        clauses = WhereClause.new(maps).execute(&block).clauses
        append(:query) do
          {
            expression_attribute_values: clauses.expression_attribute_values,
            expression_attribute_names: clauses.expression_attribute_names,
            key_condition_expression: clauses.key_condition_expression,
          }
        end
      end

      # Retrieves a key present within the composite key for this index by its
      # exact value.
      #
      # @deprecated Use {#where} instead.
      #
      # @!macro rom.dynamodb.dataset.chain_note
      #
      # @example Given Table[id<Hash>]
      #   relation.equal(:id, 1).one! #=> { id: 1, ... }
      #
      # @example Given Table[id<Hash>,created_at<Range>]
      #   relation.equal(:id, 1).equal(:created_at, Time.now.to_f).one! #=> { id: 1, ... }
      #
      # @param key [Symbol] the key to match the provided value against.
      # @param val the value to match against the key in the index.
      # @param predicate [Symbol] the query predicate to apply to DynamoDB.
      #
      # @return [self] the {Dataset} object the method was performed on.
      def equal(key, val, predicate = :eq)
        restrict_by(key, predicate, [val])
      end

      # Retrieves all matching range keys within the composite key for the
      # index between two points.
      #
      # @deprecated Use {#where} instead.
      #
      # @!macro rom.dynamodb.dataset.chain_note
      #
      # @!macro rom.dynamodb.dataset.series_note
      #
      # @example Given Table[id<Hash>,legs<Range>]
      #   users = relation.equal(:id, "mammal").between(:legs, 0, 4).to_a
      #   users #=> [{id: "mammal", legs: 2, name: "Human"}, {id: "mammal", legs: 4, name: "Elephant"}, ...]
      #
      # @param key [Symbol] the key to match the provided value against.
      # @param after the value to match range values after
      # @param before the value to match range values before
      #
      # @return [self] the {Dataset} object the method was performed on.
      def between(key, after, before, predicate = :between)
        restrict_by(key, predicate, [after, before])
      end

      # Retrieves all matching range keys within the composite key after the
      # value provided.
      #
      # @deprecated Use {#where} instead.
      #
      # @!macro rom.dynamodb.dataset.chain_note
      #
      # @!macro rom.dynamodb.dataset.series_note
      #
      # @deprecated Use {#where} instead.
      #
      # @example Given Table[id<Hash>,legs<Range>]
      #   users = relation.equal(:id, "mammal").after(:legs, 0).to_a
      #   users #=> [{id: "mammal", legs: 2, name: "Human"}, ...]
      #
      # @param key [Symbol] the key to match the provided value against.
      # @param after the value to match range values after
      # @param predicate [String] the query predicate to apply to DynamoDB.
      #
      # @return [self] the {Dataset} object the method was performed on.
      def after(key, after, predicate = :ge)
        restrict_by(key, predicate, [after])
      end

      # Retreives all matching range keys within the composite key before the
      # value provided.
      #
      # @deprecated Use {#where} instead.
      #
      # @!macro rom.dynamodb.dataset.chain_note
      #
      # @!macro rom.dynamodb.dataset.series_note
      def before(key, before, predicate = :le)
        restrict_by(key, predicate, [before])
      end

      def batch_get(query = nil)
        append(:batch_get) { query }
      end

      def restrict(query = nil)
        append(:query) { query }
      end

      def retrieve(query = nil)
        append(:get_item) { query }
      end

      def scan(query = nil)
        append(:scan) { query }
      end

      def build(parts = queries)
        parts.inject(:deep_merge).merge(table_name: name)
      end

      def update(key, hash, action = 'PUT')
        data = hash.delete_if { |k, _| key.keys.include?(k) }
        update = to_update_structure(data)
        payload = build([update, { key: key }])
        connection.update_item(payload).data
      end

      def create(hash)
        payload = build([{ item: hash }])
        connection.put_item(payload).attributes
      end

      def delete(hash)
        payload = build([{ key: hash }])
        connection.delete_item(payload).data
      end

      def information
        payload = build([{}])
        connection.describe_table(payload).table
      end

      def each(&block)
        each_item(build, &block)
      end

      def connection
        @connection ||= Aws::DynamoDB::Client.new(config)
      end

      def execute(query)
        @response ||= case operation
        when :batch_get
          connection.send(operation, { request_items: { name => query } })
        else
          connection.send(operation, query).data
        end
      end

      private

      def restrict_by(key, verb, list)
        restrict(key_conditions: {
          key => {
            comparison_operator: verb.to_s.upcase,
            attribute_value_list: list
          }
        })
      end

      def each_item(body, &block)
        case operation
        when :get_item
          block.call execute(body).item
        when :batch_get
          execute(body).responses[name.to_s].each(&block)
        else
          execute(body).items.each(&block)
        end
      end

      def append(operation = :query, &block)
        result = block.call
        if result[:key_condition_expression]

        end
        if result
          args = { name: name, config: config, operation: operation }
          self.class.new(args.merge(queries: queries + [result].flatten))
        else
          self
        end
      end

      def to_update_structure(hash)
        {
          expression_attribute_values: Hash[hash.map { |k, v| [":#{k}_u", v] }],
          expression_attribute_names: Hash[hash.map { |k, v| ["##{k}_u", v] }],
          update_expression: hash.map { |k, v| "##{k}_u=:#{k}_u" }.join(", "),
        }
      end
    end
  end
end
