# frozen_string_literal: true

require "rails_helper"

describe Support::Filter do
  let(:provider) { create(:provider) }
  let(:provider2) { create(:provider) }

  subject { Support::Filter.call(model_data_scope: Provider.all, filters: params) }

  before do
    provider
    provider2
  end

  describe "#call" do
    context "filtering with a known provider" do
      let(:params) do
        {
          text_search: provider.provider_name,
        }
      end

      it "filters the provider out" do
        expect(subject).to eq([provider])
      end
    end

    context "filtering with an unknown provider or invalid entry" do
      let(:params) do
        {
          text_search: "i can haz cheezeburger",
        }
      end

      it "returns empty relation" do
        expect(subject).to be_empty
      end
    end

    context "filtering with no filters" do
      let(:params) { {} }

      it "returns all results" do
        expect(subject.length).to eq 2
        expect(subject).to eq([provider, provider2])
      end
    end
  end
end
