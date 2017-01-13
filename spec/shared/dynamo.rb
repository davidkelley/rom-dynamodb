shared_context 'dynamo' do
  let(:table_name) { fail_on_missing_definition(:table_name) }

  let(:table) { fail_on_missing_definition(:table) }

  around { |ex| create_table_and_wait(table, &ex) }

  def dynamo
    Aws::DynamoDB::Client.new(endpoint: dynamo_endpoint)
  end

  def dynamo_endpoint
    ENV['DYNAMO_ENDPOINT'] || fail "Missing ENV['DYNAMO_ENDPOINT'] variable"
  end

  def create_table_and_wait(table, &block)
    dynamo.create_table(table)
    dynamo.wait_until(:table_exists, table_name: table_name)
    block.call
    dynamo.delete_table(table_name: table_name)
  end

  def fail_on_missing_definition(key)
    fail "let(:#{key}) definition required to use dynamo context"
  end
end
