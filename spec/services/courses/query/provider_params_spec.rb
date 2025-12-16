# frozen_string_literal: true

require "rails_helper"

RSpec.describe Courses::Query do # rubocop:disable RSpec/SpecFilePathFormat
  subject(:results) { described_class.call(params:) }

  context "when searching by provider" do
    let!(:warwick_provider) do
      create(:provider, provider_name: "Warwick University")
    end
    let!(:warwick_courses) do
      [
        create(:course, :with_full_time_sites, provider: warwick_provider, name: "Biology"),
        create(:course, :with_full_time_sites, provider: warwick_provider, name: "Computing"),
      ]
    end
    let!(:niot_provider) do
      create(:provider, provider_name: "NIoT")
    end
    let!(:niot_accredited_courses) do
      [
        create(:course, :with_full_time_sites, accredited_provider_code: niot_provider.provider_code, name: "Biology"),
        create(:course, :with_full_time_sites, accredited_provider_code: niot_provider.provider_code, name: "Computing"),
      ]
    end
    let!(:essex_provider) do
      create(:provider, provider_name: "Essex University")
    end
    let!(:essex_courses) do
      [
        create(:course, :with_full_time_sites, provider: essex_provider, name: "Biology"),
        create(:course, :with_full_time_sites, provider: essex_provider, name: "Computing"),
      ]
    end

    context "when searching by provider name for the self ratified provider" do
      let(:params) { { provider_name: "Essex University" } }

      it "returns offered courses by the provider" do
        expect(results).to match_collection(
          essex_courses,
          attribute_names: %w[id name provider_name],
        )
      end
    end

    context "when searching by provider code for the self ratified provider" do
      let(:params) { { provider_code: essex_provider.provider_code } }

      it "returns offered courses by the provider" do
        expect(results).to match_collection(
          essex_courses,
          attribute_names: %w[id name provider_name],
        )
      end
    end

    context "when searching by provider name for the accredited provider" do
      let(:params) { { provider_name: "NIoT" } }

      it "returns offered courses by the provider" do
        expect(results).to match_collection(
          niot_accredited_courses,
          attribute_names: %w[id name provider_name],
        )
      end
    end

    context "when searching by provider code for the accredited provider" do
      let(:params) { { provider_code: niot_provider.provider_code } }

      it "returns offered courses by the provider" do
        expect(results).to match_collection(
          niot_accredited_courses,
          attribute_names: %w[id name provider_name],
        )
      end
    end

    context "when no results when searching by provider name" do
      let(:params) { { provider_name: "University that does not exist" } }

      it "returns no courses" do
        expect(results).to match_collection(
          [],
          attribute_names: %w[id name provider_name],
        )
      end
    end

    context "when provider code from another cycle" do
      let!(:last_cycle) { create(:recruitment_cycle, :previous) }
      let!(:last_cycle_niot) do
        create(
          :provider,
          provider_code: niot_provider.provider_code,
          recruitment_cycle: last_cycle,
        )
      end
      let!(:last_cycle_niot_accredited_courses) do
        create_list(:course, 2, :with_full_time_sites, accredited_provider_code: last_cycle_niot.provider_code, provider: create(:provider, recruitment_cycle: last_cycle))
      end
      let!(:last_cycle_essex_provider) do
        create(:provider, provider_code: essex_provider.provider_code, recruitment_cycle: last_cycle)
      end
      let!(:last_cycle_essex_courses) do
        create_list(:course, 2, :with_full_time_sites, provider: last_cycle_essex_provider)
      end

      it "returns only accredited courses from current cycle" do
        expect(
          described_class.call(
            params: { provider_code: last_cycle_niot.provider_code },
          ),
        ).to match_collection(
          niot_accredited_courses,
          attribute_names: %w[id name provider_name recruitment_cycle],
        )
      end

      it "returns only courses from current cycle" do
        expect(
          described_class.call(
            params: { provider_code: last_cycle_essex_provider.provider_code },
          ),
        ).to match_collection(
          essex_courses,
          attribute_names: %w[id name provider_name recruitment_cycle],
        )
      end
    end
  end

  context "when searching excluding courses" do
    let(:provider) { create(:provider) }
    let(:course_code) { "EX12" }
    let(:params) { { excluded_courses: { provider_code: provider.provider_code, course_code: } } }

    it "excludes specified courses from the results" do
      create(:course, :with_full_time_sites,
             name: "Excluded Course",
             course_code:,
             provider:)

      included_course_provider = create(:provider)
      included_course = create(:course, :with_full_time_sites,
                               name: "Included Course",
                               provider: included_course_provider)

      different_provider = create(:provider)
      same_course_code_different_provider_course = create(:course, :with_full_time_sites,
                                                          name: "Included Course with same course code but different provider",
                                                          course_code:,
                                                          provider: different_provider)

      expect(results).to match_collection(
        [included_course, same_course_code_different_provider_course],
        attribute_names: %w[name],
      )
    end
  end

  context "when searching excluding courses array" do
    let(:excluded_provider) { create(:provider) }
    let(:included_course_provider) { create(:provider) }
    let(:course_code) { "EX12" }
    let(:params) { { excluded_courses: [{ provider_code: excluded_provider.provider_code, course_code: }] } }

    it "excludes specified courses from the results" do
      create(:course, :with_full_time_sites,
             name: "Excluded Course",
             course_code:,
             provider: excluded_provider)

      included_course = create(:course, :with_full_time_sites,
                               name: "Included Course",
                               provider: included_course_provider)

      same_course_code_different_provider = create(:course, :with_full_time_sites,
                                                   name: "Included Course with same course code but different provider",
                                                   course_code:,
                                                   provider: create(:provider))

      expect(results).to match_collection(
        [included_course, same_course_code_different_provider],
        attribute_names: %w[name],
      )
    end
  end
end
