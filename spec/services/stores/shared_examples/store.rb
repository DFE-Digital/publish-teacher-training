# frozen_string_literal: true

shared_examples 'store' do |identifier_model_type, form_store_keys|
  let(:identifier_model) { create(identifier_model_type) }
  let(:store) { described_class.new(identifier_model) }
  let(:redis) { double }
  let(:invalid_key_error) { "#{described_class}::InvalidKeyError".constantize }

  before do
    allow(RedisClient).to receive(:current).and_return(redis)
  end

  describe '#clear_stash' do
    subject do
      store.clear_stash(form_store_key)
    end

    let(:form_store_key) { nil }

    context 'when form_store_key is nil' do
      let(:form_store_key) { nil }

      it 'returns an error' do
        expect { subject }.to raise_error(invalid_key_error)
      end
    end

    form_store_keys.each do |store_key|
      context "when form_store_key is #{store_key}" do
        let(:form_store_key) { store_key }

        let(:value) { nil }

        if described_class == Stores::UserStore
          let(:redis_key) { "#{identifier_model.id}_#{form_store_key}" }
        else
          let(:redis_key) { "#{described_class}_#{identifier_model.id}_#{form_store_key}" }
        end

        before do
          allow(RedisClient).to receive(:current).and_return(redis)
          allow(redis).to receive(:set)
        end

        it 'does not return an error' do
          expect { subject }.not_to raise_error
        end

        it 'returns true' do
          expect(subject).to be(true)
        end

        it 'sets the redis value to nil' do
          subject
          expect(RedisClient).to have_received(:current)
          expect(redis).to have_received(:set).with(redis_key, value.to_json)
        end
      end
    end
  end

  form_store_keys.each do |store_key|
    let(:form_store_key) { store_key }

    if described_class == Stores::UserStore
      let(:redis_key) { "#{identifier_model.id}_#{form_store_key}" }
    else
      let(:redis_key) { "#{described_class}_#{identifier_model.id}_#{form_store_key}" }
    end

    describe '#stash' do
      subject do
        store.stash(form_store_key, value)
      end

      let(:value) { 'bob' }

      context 'when form_store_key is nil' do
        let(:form_store_key) { nil }

        it 'returns an error' do
          expect { subject }.to raise_error(invalid_key_error)
        end
      end

      context "when form_store_key is #{store_key}" do
        before do
          allow(redis).to receive(:set)
        end

        it 'does not return an error' do
          expect { subject }.not_to raise_error
        end

        it 'returns true' do
          expect(subject).to be(true)
        end

        it 'sets the redis value to bob' do
          subject
          expect(RedisClient).to have_received(:current)
          expect(redis).to have_received(:set).with(redis_key, value.to_json)
        end
      end
    end

    describe '#get' do
      subject do
        store.get(form_store_key)
      end

      context "when form_store_key is #{store_key}" do
        let(:redis) { double }
        let(:value) { 'builder'.to_json }

        before do
          allow(redis).to receive(:get).and_return(value)
        end

        it 'returns builder' do
          expect(subject).to eq(JSON.parse(value))
        end

        it 'sets the redis value to nil' do
          subject
          expect(RedisClient).to have_received(:current)
          expect(redis).to have_received(:get).with(redis_key)
        end
      end
    end
  end
end
