module ROM
  describe 'commands' do
    include_context 'dynamo'

    let(:descriptor) { :users }

    let(:table) { build(:table, table_name: descriptor) }

    let(:user) { build(:user) }

    let(:container) {
      ROM.container(:dynamo, credentials) do |rom|
        rom.relation(descriptor) do
          def by_id(id)
            retrieve(key: { id: id })
          end
        end

        rom.commands(descriptor) do
          KEY = Helpers::Functions[:symbolize_keys] >> Helpers::Functions[:accept_keys, [:id]]

          define(:create) { result :one }

          define(:delete) do
            result :one

            input KEY
          end

          define(:update) do
            result :one

            input KEY
          end
        end
      end
    }

    describe 'create' do
      subject(:command) { container.commands[descriptor][:create] }

      it { should_not be_nil }

      specify { expect { subject.call(user) }.to_not raise_error }
    end

    describe 'update' do
      let(:name) { Faker::Name.name }

      let(:relation) { container.relation(descriptor) }

      before { container.commands[descriptor][:create].call(user) }

      subject(:command) { container.commands[descriptor][:update] }

      specify { expect { subject.by_id(user[:id]).call(name: name) }.to change { relation.by_id(user[:id]).one!['name'] }.from(user[:name]).to(name) }
    end

    describe 'delete' do
      subject(:command) { container.commands[descriptor][:delete] }

      let(:relation) { container.relation(descriptor) }

      it { should_not be_nil }

      before { container.commands[descriptor][:create].call(user) }

      specify { expect { subject.by_id(user[:id]).call }.to_not raise_error }

      describe 'after delete' do
        before { subject.by_id(user[:id]).call }

        specify { expect { relation.by_id(user[:id]).one! }.to raise_error(ROM::TupleCountMismatchError) }
      end
    end
  end
end
