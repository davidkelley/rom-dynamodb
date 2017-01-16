shared_context 'rom' do
  include_context 'dynamo'

  let(:configuration) { ROM::Configuration.new(:dynamo, credentials) }
end
