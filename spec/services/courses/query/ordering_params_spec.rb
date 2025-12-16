# frozen_string_literal: true

require "rails_helper"

RSpec.describe Courses::Query do # rubocop:disable RSpec/SpecFilePathFormat
  subject(:results) { described_class.call(params:) }

  context "when ordering" do
    let(:niot_provider) { create(:provider, provider_name: "Niot University") }
    let(:essex_provider) { create(:provider, provider_name: "Essex University") }
    let(:oxford_provider) { create(:provider, provider_name: "Oxford University") }
    let(:manchester_provider) { create(:provider, provider_name: "Manchester University") }

    let!(:biology) do
      create(:course, :with_full_time_sites, name: "Biology", provider: niot_provider)
    end
    let!(:chemistry) do
      create(:course, :with_full_time_sites, name: "Chemistry", provider: essex_provider)
    end
    let!(:mathematics) do
      create(:course, :with_full_time_sites, name: "Mathematics", provider: oxford_provider)
    end
    let!(:art_and_design) do
      create(:course, :with_full_time_sites, name: "Art and Design", provider: manchester_provider)
    end

    context "when ordering by course name ascending" do
      let(:params) { { order: "course_name_ascending" } }

      it "returns courses ordered by course name ascending" do
        expect(results).to match_collection(
          [
            art_and_design,
            biology,
            chemistry,
            mathematics,
          ],
          attribute_names: %w[name],
        )
      end
    end

    context "when ordering by provider name ascending" do
      let(:params) { { order: "provider_name_ascending" } }

      it "returns courses ordered by provider name ascending" do
        expect(results).to match_collection(
          [
            essex_provider.courses,
            manchester_provider.courses,
            niot_provider.courses,
            oxford_provider.courses,
          ].flatten,
          attribute_names: %w[name provider_name],
        )
      end
    end

    context "when searching by provider name" do
      let(:provider) { create(:provider, provider_name: "Manchester University") }
      let!(:manchester_computing_course) do
        create(:course, :with_full_time_sites, name: "Computing", provider:)
      end
      let!(:manchester_biology_course) do
        create(:course, :with_full_time_sites, name: "Biology", provider:)
      end
      let!(:manchester_science_course) do
        create(:course, :with_full_time_sites, name: "Science", provider:)
      end
      let!(:manchester_primary_course) do
        create(:course, :with_full_time_sites, name: "Primary", provider:)
      end
      let!(:manchester_art_and_design_course) do
        create(:course, :with_full_time_sites, name: "Art and design", provider:)
      end
      let(:params) { { provider_code: provider.provider_code } }

      it "order courses by ascending order" do
        expect(results).to match_collection(
          [
            manchester_art_and_design_course,
            manchester_biology_course,
            manchester_computing_course,
            manchester_primary_course,
            manchester_science_course,
          ],
          attribute_names: %w[id name provider_name],
        )
      end
    end
  end
end
