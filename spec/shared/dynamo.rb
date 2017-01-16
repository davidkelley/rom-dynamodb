shared_context 'dynamo' do
  let(:table) { fail_on_missing_definition(:table) }

  let(:credentials) { credentials }

  around { |ex| create_table_and_wait(table, &ex) }

  def dynamo
    Aws::DynamoDB::Client.new(credentials)
  end

  def create_table_and_wait(table, &block)
    dynamo.create_table(table)
    dynamo.wait_until(:table_exists, table_name: table[:table_name])
    block.call
    dynamo.delete_table(table_name: table[:table_name])
  end

  def credentials
    {
      region: 'us-east-1',
      access_key_id: 'xxx',
      secret_access_key: 'xxx',
      endpoint: ENV['DYNAMO_ENDPOINT']
    }
  end

  def fail_on_missing_definition(key)
    fail "let(:#{key}) definition required to use dynamo context"
  end
end
