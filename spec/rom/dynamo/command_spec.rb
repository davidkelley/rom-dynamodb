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

            input Helpers::Functions[:accept_keys, :id]
          end
        end
      end
    }

    describe 'create' do
      subject(:command) { container.commands[descriptor][:create] }

      it { should_not be_nil }

      specify { expect { subject.call(user) }.to_not raise_error }
    end

    describe 'delete' do
      subject(:command) { container.commands[descriptor][:delete] }

      it { should_not be_nil }

      before { container.commands[descriptor][:create].call(user) }

      specify { expect { subject.by_id(user[:id]).call }.to_not raise_error }
    end
  end
end
