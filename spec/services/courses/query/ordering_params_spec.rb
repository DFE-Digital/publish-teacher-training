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

      context "when courses have the same name" do
        let(:alpha_provider) { create(:provider, provider_name: "Alpha University") }
        let(:zeta_provider) { create(:provider, provider_name: "Zeta University") }

        let!(:biology_alpha) do
          create(:course, :with_full_time_sites, name: "Biology", provider: alpha_provider)
        end
        let!(:biology_zeta) do
          create(:course, :with_full_time_sites, name: "Biology", provider: zeta_provider)
        end

        it "orders by provider name ascending as secondary sort" do
          biology_courses = results.select { |c| c.name == "Biology" }

          expect(biology_courses).to match_collection(
            [
              biology_alpha,
              biology,
              biology_zeta,
            ],
            attribute_names: %w[name provider_id],
          )
        end
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

      context "when a provider has multiple courses" do
        let!(:niot_art) do
          create(:course, :with_full_time_sites, name: "Art", provider: niot_provider)
        end
        let!(:niot_zoology) do
          create(:course, :with_full_time_sites, name: "Zoology", provider: niot_provider)
        end

        it "orders by course name ascending as secondary sort" do
          niot_courses = results.select { |c| c.provider_id == niot_provider.id }

          expect(niot_courses).to match_collection(
            [
              niot_art,
              biology,
              niot_zoology,
            ],
            attribute_names: %w[name provider_id],
          )
        end
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

    context "when ordering by start date ascending" do
      let(:params) { { order: "start_date_ascending" } }

      let(:september_start) { Date.new(Find::CycleTimetable.current_year, 9, 1) }
      let(:october_start) { Date.new(Find::CycleTimetable.current_year, 10, 1) }

      let(:alpha_provider) { create(:provider, provider_name: "Alpha University") }
      let(:beta_provider) { create(:provider, provider_name: "Beta University") }

      let!(:course_sept_alpha) do
        create(:course, :with_full_time_sites, name: "Physics", start_date: september_start, provider: alpha_provider)
      end
      let!(:course_sept_beta) do
        create(:course, :with_full_time_sites, name: "Physics", start_date: september_start, provider: beta_provider)
      end
      let!(:course_oct_alpha) do
        create(:course, :with_full_time_sites, name: "Physics", start_date: october_start, provider: alpha_provider)
      end

      it "orders by provider name ascending as secondary sort when start dates match" do
        physics_courses = results.select { |c| c.name == "Physics" }

        expect(physics_courses).to match_collection(
          [
            course_sept_alpha,
            course_sept_beta,
            course_oct_alpha,
          ],
          attribute_names: %w[name start_date provider_id],
        )
      end
    end

    context "when ordering by UK fee ascending" do
      let(:params) { { order: "fee_uk_ascending" } }

      let(:alpha_provider) { create(:provider, provider_name: "Alpha University") }
      let(:zeta_provider) { create(:provider, provider_name: "Zeta University") }

      let!(:course_low_fee_alpha) do
        create(
          :course,
          :with_full_time_sites,
          :fee,
          name: "Physics",
          provider: alpha_provider,
          enrichments: [build(:course_enrichment, :published, fee_uk_eu: 5000)],
        )
      end
      let!(:course_low_fee_zeta) do
        create(
          :course,
          :with_full_time_sites,
          :fee,
          name: "Physics",
          provider: zeta_provider,
          enrichments: [build(:course_enrichment, :published, fee_uk_eu: 5000)],
        )
      end
      let!(:course_high_fee) do
        create(
          :course,
          :with_full_time_sites,
          :fee,
          name: "Physics",
          provider: alpha_provider,
          enrichments: [build(:course_enrichment, :published, fee_uk_eu: 9000)],
        )
      end

      it "orders by course name then provider name ascending as secondary sort when fees match" do
        physics_courses = results.select { |c| c.name == "Physics" }

        expect(physics_courses).to match_collection(
          [
            course_low_fee_alpha,
            course_low_fee_zeta,
            course_high_fee,
          ],
          attribute_names: %w[name provider_id],
        )
      end
    end

    context "when ordering by international fee ascending" do
      let(:params) { { order: "fee_intl_ascending" } }

      let(:alpha_provider) { create(:provider, provider_name: "Alpha University") }
      let(:zeta_provider) { create(:provider, provider_name: "Zeta University") }

      let!(:course_low_fee_alpha) do
        create(
          :course,
          :with_full_time_sites,
          :fee,
          name: "Chemistry",
          provider: alpha_provider,
          enrichments: [build(:course_enrichment, :published, fee_international: 12_000)],
        )
      end
      let!(:course_low_fee_zeta) do
        create(
          :course,
          :with_full_time_sites,
          :fee,
          name: "Chemistry",
          provider: zeta_provider,
          enrichments: [build(:course_enrichment, :published, fee_international: 12_000)],
        )
      end
      let!(:course_high_fee) do
        create(
          :course,
          :with_full_time_sites,
          :fee,
          name: "Chemistry",
          provider: alpha_provider,
          enrichments: [build(:course_enrichment, :published, fee_international: 18_000)],
        )
      end

      it "orders by course name then provider name ascending as secondary sort when fees match" do
        chemistry_courses = results.select { |c| c.name == "Chemistry" }

        expect(chemistry_courses).to match_collection(
          [
            course_low_fee_alpha,
            course_low_fee_zeta,
            course_high_fee,
          ],
          attribute_names: %w[name provider_id],
        )
      end
    end
  end
end
