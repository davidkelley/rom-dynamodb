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
          define(:create) { result :one }

          define(:delete) do
            result :one

            input Functions[:symbolize_keys] >> Functions[:accept_keys, [:id]]
          end

          define(:update) do
            result :one

            input Functions[:symbolize_keys] >> Functions[:accept_keys, [:id]]
          end
        end
      end
    }

    let(:relation) { container.relation(descriptor) }

    describe 'create' do
      subject(:command) { container.commands[descriptor][:create] }

      describe 'command' do
        it { should_not be_nil }
      end

      specify { expect { subject.call(user) }.to change { relation.count }.by(1) }

      specify { expect { subject.call(user) }.to_not raise_error }
    end

    describe 'update' do
      let(:name) { Faker::Name.name }

      before { container.commands[descriptor][:create].call(user) }

      subject(:command) { container.commands[descriptor][:update] }

      describe 'command' do
        it { should_not be_nil }
      end

      specify { expect { subject.by_id(user[:id]).call(name: name) }.to_not change { relation.count } }

      specify { expect { subject.by_id(user[:id]).call(name: name) }.to change { relation.by_id(user[:id]).one!['name'] }.from(user[:name]).to(name) }
    end

    describe 'delete' do
      subject(:command) { container.commands[descriptor][:delete] }

      before { container.commands[descriptor][:create].call(user) }

      describe 'command' do
        it { should_not be_nil }
      end

      specify { expect { subject.by_id(user[:id]).call }.to change { relation.count }.by(-1) }

      describe 'before delete' do
        specify { expect { relation.by_id(user[:id]).one! }.to_not raise_error }
      end

      describe 'after delete' do
        before { subject.by_id(user[:id]).call }

        specify { expect { relation.by_id(user[:id]).one! }.to raise_error(ROM::TupleCountMismatchError) }
      end
    end
  end
end
