module ROM
  module DynamoDB
    class Dataset
      class WhereClause
        class Clause
          attr_reader :clauses

          def initialize(clauses = [])
            @clauses = clauses.is_a?(Array) ? clauses : [clauses]
          end

          def concat(val)
            @clauses.concat(val.is_a?(Array) ? val : [val])
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
              value = clause.val
              min = value.min.is_a?(Operand) ? value.min.val : value.min
              max = value.max.is_a?(Operand) ? value.max.val : value.max
              {
                ":#{clause.key}_a" => min,
                ":#{clause.key}_b" => max
              }
            else
              { ":#{clause.key}" => clause.val }
            end
          end

          def to_names(clause)
            { "##{clause.key}" => clause.key }
          end
        end

        class Operand
          attr_reader :key, :operand, :val

          def initialize(key:, val:)
            @key = key
            @val = val
          end

          %i(<= == >= > < between).each do |com|
            define_method(com) do |val|
              @operand = com
              @val = val.is_a?(Operand) ? val.val : val
              self
            end
          end

          def <=>(op)
            val <=> op.val
          end
        end

        attr_reader :maps, :clauses

        def initialize(maps = {})
          @clauses = Clause.new
          @maps = maps
        end

        def execute(&block)
          @clauses.concat(instance_exec(&block))
          self
        end

        def method_missing(key)
          Operand.new(key: key, val: maps[key])
        end
      end
    end
  end
end
