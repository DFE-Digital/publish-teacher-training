# frozen_string_literal: true

require "rails_helper"

RSpec.describe CourseWizard::Draft, type: :wizard do
  subject(:draft) { described_class.new(wizard:) }

  include_context "add_course_wizard"

  let(:current_step) { :check_answers }

  describe "delegated readers" do
    before do
      state_store.write(
        level: "secondary",
        is_send: "false",
        qualification: "pgce_with_qts",
        campaign_name: "no_campaign",
        start_date: "July 2027",
        primary_master_subject_id: "11",
        secondary_master_subject_id: "12",
        subordinate_subject_id: "13",
        can_sponsor_student_visa: true,
        can_sponsor_skilled_worker_visa: false,
        visa_sponsorship_application_deadline_required: true,
        accredited_provider_code: provider.provider_code,
      )
    end

    it "delegates simple state attributes" do
      aggregate_failures do
        expect(draft.level).to eq("secondary")
        expect(draft.is_send).to eq("false")
        expect(draft.qualification).to eq("pgce_with_qts")
        expect(draft.campaign_name).to eq("no_campaign")
        expect(draft.start_date).to eq("July 2027")
        expect(draft.primary_master_subject_id).to eq("11")
        expect(draft.secondary_master_subject_id).to eq("12")
        expect(draft.subordinate_subject_id).to eq("13")
        expect(draft.can_sponsor_student_visa).to be(true)
        expect(draft.can_sponsor_skilled_worker_visa).to be(false)
        expect(draft.visa_sponsorship_application_deadline_required).to be(true)
        expect(draft.accredited_provider_code).to eq(provider.provider_code)
      end
    end
  end

  describe "subject resolution" do
    before do
      state_store.write(level: "secondary")
    end

    it "includes specialism ids only when those specialism steps are active" do
      physics = find_or_create(:secondary_subject, :physics)
      modern_languages = find_or_create(:secondary_subject, :modern_languages)
      french = find_or_create(:secondary_subject, :french)
      design_technology = find_or_create(:secondary_subject, :design_and_technology)

      state_store.write(
        secondary_master_subject_id: physics.id.to_s,
        subordinate_subject_id: modern_languages.id.to_s,
        language_ids: [french.id.to_s],
        design_technology_ids: [design_technology.id.to_s],
      )

      expect(draft.subject_ids).to include(physics.id.to_s, modern_languages.id.to_s, french.id.to_s)
      expect(draft.subject_ids).not_to include(design_technology.id.to_s)
    end

    it "returns no subject ids for further education" do
      state_store.write(level: "further_education")

      expect(draft.subject_ids).to eq([])
    end
  end

  describe "TDA defaults" do
    before do
      state_store.write(qualification: "undergraduate_degree_with_qts", funding_type: nil, study_pattern: nil)
    end

    it "defaults funding plus full-time study mode for display and serializer" do
      expect(draft.tda?).to be(true)
      expect(draft.funding).to eq("apprenticeship")
      expect(draft.study_patterns_for_display).to eq(%w[full_time])
      expect(draft.study_modes).to eq(%w[full_time])
      expect(draft).to be_employment_based
    end
  end

  describe "funding and study modes for non-TDA" do
    before do
      state_store.write(qualification: "pgce_with_qts")
    end

    it "uses explicit funding type and employment predicate" do
      state_store.write(funding_type: "salary")

      expect(draft.funding).to eq("salary")
      expect(draft).to be_employment_based
    end

    it "returns false for employment_based? for fee-funded courses" do
      state_store.write(funding_type: "fee")

      expect(draft).not_to be_employment_based
    end

    it "returns provided study patterns for both serializer and display methods" do
      state_store.write(study_pattern: %w[full_time part_time])

      expect(draft.study_modes).to eq(%w[full_time part_time])
      expect(draft.study_patterns_for_display).to eq(%w[full_time part_time])
    end

    it "returns empty arrays when study_pattern is blank" do
      state_store.write(study_pattern: nil)

      expect(draft.study_modes).to eq([])
      expect(draft.study_patterns_for_display).to eq([])
    end
  end

  describe "age range mapping" do
    it "maps custom age range into the combined persisted key" do
      state_store.write(
        age_range_in_years: "other",
        course_age_range_in_years_other_from: "14",
        course_age_range_in_years_other_to: "19",
      )

      expect(draft.age_range_choice).to eq("other")
      expect(draft.age_range_in_years).to eq("14_to_19")
    end

    it "delegates custom age bounds" do
      state_store.write(
        course_age_range_in_years_other_from: "5",
        course_age_range_in_years_other_to: "11",
      )

      expect(draft.course_age_range_in_years_other_from).to eq("5")
      expect(draft.course_age_range_in_years_other_to).to eq("11")
    end
  end

  describe "subject/site/provider lookup helpers" do
    it "resolves master_subject_id for primary, secondary and further education" do
      primary_subject = find_or_create(:primary_subject, :primary)
      secondary_subject = find_or_create(:secondary_subject, :physics)

      state_store.write(level: "primary", primary_master_subject_id: primary_subject.id.to_s)
      expect(draft.master_subject_id).to eq(primary_subject.id.to_s)

      state_store.write(level: "secondary", secondary_master_subject_id: secondary_subject.id.to_s)
      expect(draft.master_subject_id).to eq(secondary_subject.id.to_s)

      state_store.write(level: "further_education")
      expect(draft.master_subject_id).to be_nil
    end

    it "returns ordered subject records" do
      first = find_or_create(:secondary_subject, :physics)
      second = find_or_create(:secondary_subject, :business_studies)
      state_store.write(level: "secondary", secondary_master_subject_id: first.id.to_s, subordinate_subject_id: second.id.to_s)

      expect(draft.subjects.map(&:id)).to eq([first.id, second.id])
    end

    it "returns school ids and ordered school records" do
      site_one = provider.sites.first || create(:site, provider:)
      site_two = create(:site, provider:)
      state_store.write(site_ids: [site_two.id.to_s, site_one.id.to_s])

      expect(draft.school_ids).to eq([site_two.id.to_s, site_one.id.to_s])
      expect(draft.schools.map(&:id)).to eq([site_two.id, site_one.id])
    end

    it "returns study site ids and ordered study sites" do
      first = provider.study_sites.first || create(:site, :study_site, provider:)
      second = create(:site, :study_site, provider:)
      state_store.write(study_sites_ids: [second.id.to_s, first.id.to_s])

      expect(draft.study_site_ids).to eq([second.id.to_s, first.id.to_s])
      expect(draft.selected_study_site_ids).to eq([second.id.to_s, first.id.to_s])
      expect(draft.study_sites.map(&:id)).to eq([second.id, first.id])
    end

    it "returns nil study_site_ids when unset" do
      state_store.write(study_sites_ids: nil)

      expect(draft.study_site_ids).to be_nil
      expect(draft.selected_study_site_ids).to eq([])
      expect(draft.study_sites).to eq([])
    end

    it "delegates accrediting_provider and resolves accreditation provider name" do
      accrediting_provider = instance_double(Provider)
      allow(wizard).to receive(:accrediting_provider).and_return(accrediting_provider)
      state_store.write(accredited_provider_code: provider.provider_code)

      expect(draft.accrediting_provider).to eq(accrediting_provider)
      expect(draft.accreditation_provider_name).to eq(provider.provider_name)
    end
  end

  describe "visa deadline parsing" do
    it "normalizes DateParts for shared display/serialization use" do
      state_store.write(
        visa_sponsorship_application_deadline_at: CourseWizard::Steps::VisaSponsorshipApplicationDeadlineAt::DateParts.new("2027", "3", "1"),
      )

      expect(draft.visa_deadline.year).to eq(2027)
      expect(draft.visa_deadline.month).to eq(3)
      expect(draft.visa_deadline.day).to eq(1)
      expect(draft.visa_deadline.to_formatted_string).to eq(Date.new(2027, 3, 1).to_fs(:govuk_date))
    end
  end
end
