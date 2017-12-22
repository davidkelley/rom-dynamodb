module ROM
  describe 'Key: { host<HASH>, logged_at<RANGE> } table' do
    include_context 'dynamo'

    let(:sequence_step) { 60 }

    let(:descriptor) { :logs }

    let(:table) {
      build(:table, {
        table_name: descriptor,
        definitions: { host: :S, logged_at: :N },
        schema: { host: :HASH, logged_at: :RANGE }
      })
    }

    let(:count) { rand(10..20) }

    let(:host) { Faker::Internet.ip_v6_address }

    let(:logs) { build_list(:log, count, host: host, sequence_step: sequence_step) }

    let(:container) {
      ROM.container(:dynamodb, credentials) do |rom|
        rom.relation(descriptor) do
          def by_host(host)
            equal(:host, host)
          end

          def by_logged_at(logged_at)
            equal(:logged_at, logged_at)
          end

          def logged_at_after(val)
            after(:logged_at, val)
          end

          def logged_at_before(val)
            before(:logged_at, val)
          end

          def logged_at_between(after, before)
            between(:logged_at, after, before)
          end
        end

        rom.commands(descriptor) do
          define(:create) { result :one }
        end
      end
    }

    subject(:relation) { container.relations[descriptor] }

    before { container.commands[descriptor][:create].call(logs) }

    describe '#equal' do
      describe 'exact' do
        let(:time) { logs.sample[:logged_at] }

        specify { expect(relation.where(host: host, time: time) { [host == host, logged_at == time] }.to_a.size).to eq 1 }

        specify(:deprecated) { expect(relation.by_host(host).by_logged_at(time).to_a.size).to eq 1 }
      end

      describe 'none' do
        let(:time) { 0 }

        specify { expect(relation.where(host: host) { [host == host, logged_at == 0] }.to_a.size).to eq 0 }

        specify(:deprecated) { expect(relation.by_host(host).by_logged_at(time).to_a.size).to eq 0 }
      end
    end

    describe '#between' do
      describe 'most' do
        let(:left) { rand(1..(count/2).floor) }

        let(:right) { rand((count/2).ceil..(count - 1).ceil) }

        let(:log_range) { logs[left..right] }

        let(:after) { log_range.first[:logged_at] }

        let(:before) { log_range.last[:logged_at] }

        let(:predicates) { { host: host, after: after, before: before } }

        specify { expect(relation.where(predicates) { [host == host, logged_at.between(after..before)] }.to_a.size).to eq log_range.size }

        specify(:deprecated) { expect(relation.by_host(host).logged_at_between(after, before).to_a.size).to eq log_range.size }

        describe 'with limit' do
          let(:limit) { (log_range.size / 2).ceil }

          specify { expect(relation.where(predicates) { [host == host, logged_at.between(after..before)] }.limit(limit).to_a.size).to eq limit }

          specify(:deprecated) { expect(relation.by_host(host).logged_at_between(after, before).limit(limit).to_a.size).to eq limit }
        end
      end
    end

    describe '#before' do
      describe 'all' do
        let(:time) { Time.now.to_i + (60 * 60 * 24 * 7 * 52) }

        let(:predicates) { { host: host, time: time } }

        specify { expect(relation.where(predicates) { [host == host, logged_at <= time] }.to_a.size).to eq count }

        specify(:deprecated) { expect(relation.by_host(host).logged_at_before(time).to_a.size).to eq count }

        describe 'with limit' do
          let(:limit) { (count / 2).ceil }

          specify { expect(relation.where(predicates) { [host == host, logged_at <= time] }.limit(limit).to_a.size).to eq limit }

          specify(:deprecated) { expect(relation.by_host(host).logged_at_before(time).limit(limit).to_a.size).to eq limit }
        end
      end

      describe 'some' do
        let(:right) { rand((count/2).ceil..(count - 1).ceil) }

        let(:log_range) { logs[0..right] }

        let(:time) { log_range.last[:logged_at] }

        let(:predicates) { { host: host, time: time } }

        specify { expect(relation.where(predicates) { [host == host, logged_at <= time] }.to_a.size).to eq log_range.size }

        specify(:deprecated) { expect(relation.by_host(host).logged_at_before(time).to_a.size).to eq log_range.size }

        describe 'with limit' do
          let(:limit) { (log_range.size / 2).ceil }

          specify { expect(relation.where(predicates) { [host == host, logged_at <= time] }.limit(limit).to_a.size).to eq limit }

          specify(:deprecated) { expect(relation.by_host(host).logged_at_before(time).limit(limit).to_a.size).to eq limit }
        end
      end

      describe 'none' do
        let(:time) { Time.now.to_i - (60 * 60 * 24 * 7 * 52) }

        let(:predicates) { { host: host, time: time } }

        specify { expect(relation.where(predicates) { [host == host, logged_at <= time] }.to_a).to be_empty }

        specify(:deprecated) { expect(relation.by_host(host).logged_at_before(time).to_a).to be_empty }
      end
    end

    describe '#after' do
      describe 'all' do
        let(:time) { Time.now.to_i - (sequence_step * count) }

        let(:predicates) { { host: host, time: time } }

        specify { expect(relation.where(predicates) { [host == host, logged_at >= time] }.to_a.size).to eq count }

        specify(:deprecated) { expect(relation.by_host(host).logged_at_after(time).to_a.size).to eq count }

        describe 'with limit' do
          let(:limit) { (count / 2).ceil }

          specify { expect(relation.where(predicates) { [host == host, logged_at >= time] }.limit(limit).to_a.size).to eq limit }

          specify(:deprecated) { expect(relation.by_host(host).logged_at_after(time).limit(limit).to_a.size).to eq limit }
        end
      end

      describe 'some' do
        let(:left) { rand(1..(count/2).floor) }

        let(:log_range) { logs[left..(logs.size - 1)] }

        let(:time) { log_range.first[:logged_at] }

        let(:predicates) { { host: host, time: time } }

        specify { expect(relation.where(predicates) { [host == host, logged_at >= time] }.to_a.size).to eq log_range.size }

        specify(:deprecated) { expect(relation.by_host(host).logged_at_after(time).to_a.size).to eq log_range.size }

        describe 'with limit' do
          let(:limit) { (log_range.size / 2).ceil }

          specify { expect(relation.where(predicates) { [host == host, logged_at >= time] }.limit(limit).to_a.size).to eq limit }

          specify(:deprecated) { expect(relation.by_host(host).logged_at_after(time).limit(limit).to_a.size).to eq limit }
        end
      end

      describe 'none' do
        let(:time) { Time.now.to_i + (60 * 60 * 24 * 7 * 52) }

        let(:predicates) { { host: host, time: time } }

        specify { expect(relation.where(predicates) { [host == host, logged_at >= time] }.to_a).to be_empty }

        specify(:deprecated) { expect(relation.by_host(host).logged_at_after(time).to_a).to be_empty }
      end
    end
  end

  describe 'Key: { id<HASH> } table' do
    include_context 'dynamo'

    let(:descriptor) { :users }

    let(:table) { build(:table, table_name: descriptor) }

    let(:count) { rand(10..20) }

    let(:users) { build_list(:user, count) }

    let(:user) { users.sample }

    let(:container) {
      ROM.container(:dynamodb, credentials) do |rom|
        rom.relation(descriptor) do
          def by_id(id)
            retrieve(key: { id: id })
          end

          def by(val)
            where { id == val }
          end
        end

        rom.commands(descriptor) do
          define(:create) { result :one }
        end
      end
    }

    subject(:relation) { container.relations[descriptor] }

    before { container.commands[descriptor][:create].call(users) }

    it { should respond_to(:by_id) }

    describe '#count' do
      subject { relation.count }

      it { should be_a Fixnum }

      it { should be > 0 }
    end

    describe '#status' do
      subject { relation.status }

      it { should be_a Symbol }

      specify { expect(subject.to_s).to match /[a-z]+/ }
    end

    specify { expect(container.commands[descriptor]).to_not be_nil }

    specify { expect { relation.by(user[:id]).one! }.to_not raise_error }

    specify { expect { relation.by(user[:id] * 2).one! }.to raise_error(ROM::TupleCountMismatchError) }

    specify { expect { relation.where(id: user[:id]) { id == id }.one! }.to_not raise_error }

    specify { expect { relation.where(id: user[:id] * 2) { id == id }.one! }.to raise_error(ROM::TupleCountMismatchError) }

    specify(:deprecated) { expect { relation.by_id(user[:id]).one! }.to_not raise_error }

    specify(:deprecated) { expect { relation.by_id(user[:id] * 2).one! }.to raise_error(ROM::TupleCountMismatchError) }
  end
end
