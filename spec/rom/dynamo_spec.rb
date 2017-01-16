module ROM
  describe Dynamo do
    include_context 'dynamo'

    let(:table) { build(:table) }

    specify { expect { ROM::Configuration.new(:dynamo, credentials) }.to_not raise_error }

    specify { expect { {}.deep_merge(credentials) }.to_not raise_error }
  end
end
