# frozen_string_literal: true

require "rails_helper"

describe Support::Filter do
  subject { Support::Filter.call(model_data_scope: model_scope, filters: params) }

  describe "#call" do
    context "with Provider as model_scope" do
      let(:model_scope) { Provider.all }

      let!(:provider) { create(:provider, provider_name: "Really big school", provider_code: "A01", courses: [build(:course, course_code: "2VVZ")]) }
      let!(:provider2) { create(:provider, provider_name: "Slightly smaller school", provider_code: "A02", courses: [build(:course, course_code: "2VVZ")]) }

      context "filtering with a known provider" do
        let(:params) do
          {
            provider_search: provider.provider_name,
          }
        end

        it "filters the provider out" do
          expect(subject).to match_array([provider])
        end
      end

      context "filtering with an unknown provider or invalid entry" do
        let(:params) do
          {
            provider_search: "i can haz cheezeburger",
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

    context "with User as model_scope" do
      let(:model_scope) { User.all }

      let!(:user) { create(:user, first_name: "The dude") }

      context "filtering with a known user" do
        let(:params) do
          {
            text_search: user.first_name,
          }
        end

        it "filters the provider out" do
          expect(subject).to eq([user])
        end
      end
    end

    context "with Allocation as model_scope" do
      let(:model_scope) { Allocation.all }

      let!(:allocation) { create(:allocation, number_of_places: 1) }

      context "filtering with a known allocation provider" do
        let(:params) do
          {
            text_search: allocation.provider.provider_name,
          }
        end

        it "filters the provider out" do
          expect(subject).to eq([allocation])
        end
      end
    end
  end
end
