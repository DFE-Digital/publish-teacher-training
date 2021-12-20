# frozen_string_literal: true

require "rails_helper"

describe Support::Filters::ProviderFilter do
  let(:permitted_params) { ActionController::Parameters.new(provider_and_course_params).permit(:provider_search, :course_search) }

  subject { described_class.new(params: permitted_params) }

  describe "#filters" do
    context "with fully valid parameters" do
      let(:provider_and_course_params) do
        {
          provider_search: "search terms",
          course_search: "course search terms",
        }
      end

      it "returns the correct filter hash" do
        expect(subject.filters).to eq(permitted_params.to_h)
      end
    end

    context "with empty params" do
      let(:provider_and_course_params) { {} }

      it "returns nil" do
        expect(subject.filters).to be_nil
      end
    end

    context "provider and course params from providers controller" do
      subject { described_class.new(params: permitted_params) }

      context "with fully valid course and provider parameters" do
        let(:provider_and_course_params) do
          {
            provider_search: "T92",
            course_search: "X130",
          }
        end

        it "returns the correct filter hash" do
          expect(subject.filters).to eq(permitted_params.to_h)
        end
      end

      context "with fully valid provider parameters" do
        let(:provider_and_course_params) do
          {
            provider_search: "T92",
            course_search: "",
          }
        end

        it "returns the correct filter hash" do
          expect(subject.filters).to eq(permitted_params.to_h)
        end
      end

      context "with fully valid course parameters" do
        let(:provider_and_course_params) do
          {
            provider_search: "",
            course_search: "X130",
          }
        end

        it "returns the correct filter hash" do
          expect(subject.filters).to eq(permitted_params.to_h)
        end
      end

      context "with empty params" do
        let(:provider_and_course_params) { {} }

        it "returns nil" do
          expect(subject.filters).to be_nil
        end
      end
    end
  end
end
