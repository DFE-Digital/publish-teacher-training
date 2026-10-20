# frozen_string_literal: true

shared_examples "store" do |identifier_model_type, form_store_keys|
  let(:identifier_model) { create(identifier_model_type) }
  let(:store) { described_class.new(identifier_model) }
  let(:invalid_key_error) { "#{described_class}::InvalidKeyError".constantize }

  it { expect(described_class::FORM_STORE_KEYS).to match_array(form_store_keys) }

  it "rejects keys it does not own" do
    expect { store.stash(nil, "bob") }.to raise_error(invalid_key_error)
    expect { store.get(:unknown) }.to raise_error(invalid_key_error)
    expect { store.clear_stash(nil) }.to raise_error(invalid_key_error)
  end

  describe "when Solid Cache is unavailable" do
    let(:store_key) { form_store_keys.first }
    let(:cache_error) { ActiveRecord::ConnectionNotEstablished.new("cache unavailable") }

    it "raises instead of continuing after a failed write" do
      allow(SolidCache::Entry).to receive(:write).and_raise(cache_error)

      expect { store.stash(store_key, "bob") }
        .to raise_error(ActiveRecord::ConnectionNotEstablished, "cache unavailable")
    end

    it "raises instead of treating a failed read as missing data" do
      allow(SolidCache::Entry).to receive(:read).and_raise(cache_error)

      expect { store.get(store_key) }
        .to raise_error(ActiveRecord::ConnectionNotEstablished, "cache unavailable")
    end

    it "raises instead of leaving stale data after a failed delete" do
      allow(SolidCache::Entry).to receive(:delete_by_key).and_raise(cache_error)

      expect { store.clear_stash(store_key) }
        .to raise_error(ActiveRecord::ConnectionNotEstablished, "cache unavailable")
    end
  end

  form_store_keys.each do |store_key|
    context "with #{store_key}" do
      let(:cache_key) { "form_stores/#{described_class}_#{identifier_model.id}_#{store_key}" }

      it "stashes and reads back the value" do
        expect(store.stash(store_key, { "name" => "bob" })).to be(true)

        expect(store.get(store_key)).to eq("name" => "bob")
      end

      it "writes to a namespaced Solid Cache key" do
        store.stash(store_key, "bob")

        expect(Stores::BaseStore.cache.read(cache_key)).to eq("bob".to_json)
      end

      it "expires after 24 hours" do
        store.stash(store_key, "bob")

        travel(23.hours) { expect(store.get(store_key)).to eq("bob") }
        travel(25.hours) { expect(store.get(store_key)).to be_nil }
      end

      it "clears the stash" do
        store.stash(store_key, "bob")

        expect(store.clear_stash(store_key)).to be(true)
        expect(store.get(store_key)).to be_nil
      end

    end
  end
end
