module ROM
  module DynamoDB
    class Gateway < ROM::Gateway
      attr_reader :datasets, :config

      def initialize(config = {})
        @config = config
        @datasets ||= {}
      end

      def dataset(name)
        datasets[name] ||= Dataset.new(name: name, config: config)
      end

      def dataset?(name)
        list = connection.list_tables
        list.table_names.include?(name)
      end

      def connection
        @connection ||= Aws::DynamoDB::Client.new(@config)
      end
    end
  end
end
