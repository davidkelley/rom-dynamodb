module ROM
  describe 'Key: { id } table' do
    include_context 'dynamo'

    let(:descriptor) { :users }

    let(:table) { build(:table, table_name: descriptor) }

    let(:users) { build_list(:user, 10) }

    let(:user) { users.sample }

    let(:container) {
      ROM.container(:dynamo, credentials) do |rom|
        rom.relation(descriptor) do
          def by_id(id)
            retrieve(key: { id: id })
          end
        end

        rom.commands(descriptor) do
          define(:create) { result :one }
        end
      end
    }

    subject(:relation) { container.relation(descriptor) }

    before { container.commands[descriptor][:create].call(users) }

    it { should respond_to(:by_id) }

    specify { expect(container.commands[descriptor]).to_not be_nil }

    specify { expect { relation.by_id(user[:id]).one! }.to_not raise_error }

    specify { expect { relation.by_id(user[:id] * 2).one! }.to raise_error(ROM::TupleCountMismatchError) }
  end
end
