require "rails_helper"

describe UserStore do
  let(:user) { create(:user) }
  let(:store) { described_class.new(user) }
  let(:form_store_key) { :user }
  let(:redis) { double }

  before do
    allow(RedisClient).to receive(:current).and_return(redis)
  end

  describe "#clear_stash" do
    subject do
      store.clear_stash(form_store_key)
    end

    context "when form_store_key is nil" do
      let(:form_store_key) { nil }

      it "returns an error" do
        expect { subject }.to raise_error(UserStore::InvalidKeyError)
      end
    end

    context "when form_store_key is user" do
      let(:value) { nil }

      before do
        allow(RedisClient).to receive(:current).and_return(redis)
        allow(redis).to receive(:set)
      end

      it "does not return an error" do
        expect { subject }.not_to raise_error
      end

      it "returns true" do
        expect(subject).to be(true)
      end

      it "sets the redis value to nil" do
        subject
        expect(RedisClient).to have_received(:current)
        expect(redis).to have_received(:set).with("#{user.id}_#{form_store_key}", value.to_json)
      end
    end
  end

  describe "#stash" do
    subject do
      store.stash(form_store_key, value)
    end

    let(:value) { "bob" }

    context "when form_store_key is nil" do
      let(:form_store_key) { nil }

      it "returns an error" do
        expect { subject }.to raise_error(UserStore::InvalidKeyError)
      end
    end

    context "when form_store_key is user" do
      before do
        allow(redis).to receive(:set)
      end

      it "does not return an error" do
        expect { subject }.not_to raise_error
      end

      it "returns true" do
        expect(subject).to be(true)
      end

      it "sets the redis value to bob" do
        subject
        expect(RedisClient).to have_received(:current)
        expect(redis).to have_received(:set).with("#{user.id}_#{form_store_key}", value.to_json)
      end
    end
  end

  describe "#get" do
    subject do
      store.get(form_store_key)
    end

    context "when form_store_key is user" do
      let(:redis) { double }
      let(:value) { "builder".to_json }

      before do
        allow(redis).to receive(:get).and_return(value)
      end

      it "returns builder" do
        expect(subject).to eq(JSON.parse(value))
      end

      it "sets the redis value to nil" do
        subject
        expect(RedisClient).to have_received(:current)
        expect(redis).to have_received(:get).with("#{user.id}_#{form_store_key}")
      end
    end
  end
end
