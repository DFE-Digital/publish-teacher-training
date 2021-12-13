# frozen_string_literal: true

require "rails_helper"

describe Support::Filter do
  let(:provider) { create(:provider, provider_name: "Really big school", provider_code: "A01", courses: [build(:course, course_code: "2VVZ")]) }
  let(:provider2) { create(:provider, provider_name: "Slightly smaller school", provider_code: "A02", courses: [build(:course, course_code: "2VVZ")]) }

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

    context "filtering with a known provider and course code" do
      let(:params) do
        {
          provider_search: "A01",
          course_search: provider.courses.first.course_code,
        }
      end

      it "filters the provider out" do
        expect(subject).to eq([provider])
      end
    end

    context "filtering with a known provider only" do
      let(:params) do
        {
          provider_search: "A01",
          course_search: "",
        }
      end

      it "filters the provider out" do
        expect(subject).to eq([provider])
      end
    end

    context "filtering with a known course code only" do
      let(:params) do
        {
          provider_search: "",
          course_search: "2VVZ",
        }
      end

      it "filters the provider out" do
        expect(subject).to match_array([provider, provider2])
      end
    end
  end
end
