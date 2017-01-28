module ROM
  module DynamoDB
    class Dataset
      class WhereClause
        class Clause
          attr_reader :clauses

          def initialize(clauses = [])
            @clauses = clauses.is_a?(Array) ? clauses : [clauses]
          end

          def expression_attribute_values
            clauses.collect(&method(:to_values)).inject(:merge)
          end

          def expression_attribute_names
            clauses.collect(&method(:to_names)).inject(:merge)
          end

          def key_condition_expression
            clauses.collect(&method(:to_expression)).join(" AND ")
          end

          def to_expression(clause)
            case clause.operand
            when :between
              "##{clause.key} BETWEEN :#{clause.key}_a AND :#{clause.key}_b"
            when :begins_with
              "begins_with(##{clause.key}, :#{clause.key})"
            when :==
              "##{clause.key} = :#{clause.key}"
            else
              "##{clause.key} #{clause.operand} :#{clause.key}"
            end
          end

          def to_values(clause)
            case clause.operand
            when :between
              {
                ":#{clause.key}_a" => clause.val.min,
                ":#{clause.key}_b" => clause.val.max
              }
            else
              { ":#{clause.key}" => clause.val }
            end
          end

          def to_names(clause)
            { "##{c.key}" => c.key }
          end
        end

        class Operand
          attr_reader :key, :operand, :val

          def initialize(key)
            @key = key
          end

          %i(<= == >= > < between).each do |com|
            define_method(com) do |val|
              @operand = com
              @val = val
              self
            end
          end
        end

        attr_reader :maps, :clauses

        def initialize(maps = {})
          @maps = maps
        end

        def execute(&block)
          Clause.new(instance_exec(&block))
        end

        def method_missing(key)
          maps[key] || Operand.new(key)
        end
      end
    end
  end
end
