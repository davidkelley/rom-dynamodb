describe ROM::Dynamo do
  include_context "dynamo"

  let(:schema) {
    {
      definitions: { id: :N, range: :N },
      schema: { id: :HASH, range: :RANGE }
    }
  }

  let(:table) { build(:table, **schema) }

  it "has a version number" do
    expect(ROM::Dynamo::VERSION).not_to be nil
  end
end
