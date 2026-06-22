# frozen_string_literal: true

require "rails_helper"

RSpec.describe "CourseWizard#next_step", type: :wizard do
  include_context "add_course_wizard"

  context "from level" do
    let(:current_step) { :level }

    context "when primary is selected" do
      before do
        state_store.write(level: "primary")
      end

      it "proceeds to primary subjects" do
        expect(wizard).to have_next_step(:primary_subjects)
      end
    end

    context "when secondary is selected" do
      before do
        state_store.write(level: "secondary")
      end

      it "proceeds to secondary subjects" do
        expect(wizard).to have_next_step(:secondary_subjects)
      end
    end

    context "when further education is selected" do
      before do
        state_store.write(level: "further_education")
      end

      it "proceeds to courses page" do
        expect(wizard).to have_next_step(:qualifications)
      end
    end
  end

  context "from primary subjects" do
    let(:current_step) { :primary_subjects }

    it "proceeds to age range page" do
      expect(wizard).to have_next_step(:age_range)
    end
  end

  context "from secondary subjects" do
    let(:current_step) { :secondary_subjects }

    before do
      state_store.write(level: "secondary", is_send: false)
    end

    it "proceeds to age range page" do
      expect(wizard).to have_next_step(:age_range)
    end

    context "when physics is selected as first subject" do
      before do
        state_store.write(secondary_master_subject_id: find_or_create(:secondary_subject, :physics).id.to_s)
      end

      it "proceeds to physics specialisms page" do
        expect(wizard).to have_next_step(:physics_specialisms)
      end
    end

    context "when modern languages is selected as second subject" do
      before do
        state_store.write(
          secondary_master_subject_id: find_or_create(:secondary_subject, :business_studies).id.to_s,
          subordinate_subject_id: find_or_create(:secondary_subject, :modern_languages).id.to_s,
        )
      end

      it "proceeds to modern languages specialisms page" do
        expect(wizard).to have_next_step(:modern_languages_specialisms)
      end
    end

    context "when design and technology is selected as second subject" do
      before do
        state_store.write(
          secondary_master_subject_id: find_or_create(:secondary_subject, :business_studies).id.to_s,
          subordinate_subject_id: find_or_create(:secondary_subject, :design_and_technology).id.to_s,
        )
      end

      it "proceeds to design technology specialisms page" do
        expect(wizard).to have_next_step(:design_technology_specialisms)
      end
    end

    context "when physics and modern languages are both selected" do
      before do
        state_store.write(
          secondary_master_subject_id: find_or_create(:secondary_subject, :physics).id.to_s,
          subordinate_subject_id: find_or_create(:secondary_subject, :modern_languages).id.to_s,
        )
      end

      it "proceeds to physics specialisms first" do
        expect(wizard).to have_next_step(:physics_specialisms)
      end
    end

    context "when modern languages and design and technology are both selected" do
      before do
        state_store.write(
          secondary_master_subject_id: find_or_create(:secondary_subject, :modern_languages).id.to_s,
          subordinate_subject_id: find_or_create(:secondary_subject, :design_and_technology).id.to_s,
        )
      end

      it "proceeds to modern languages specialisms first" do
        expect(wizard).to have_next_step(:modern_languages_specialisms)
      end
    end
  end

  context "from physics specialisms" do
    let(:current_step) { :physics_specialisms }

    before do
      state_store.write(level: "secondary", is_send: false)
    end

    context "when modern languages is selected" do
      before do
        state_store.write(
          secondary_master_subject_id: find_or_create(:secondary_subject, :physics).id.to_s,
          subordinate_subject_id: find_or_create(:secondary_subject, :modern_languages).id.to_s,
        )
      end

      it "proceeds to modern languages specialisms page" do
        expect(wizard).to have_next_step(:modern_languages_specialisms)
      end
    end

    context "when design and technology is selected without modern languages" do
      before do
        state_store.write(
          secondary_master_subject_id: find_or_create(:secondary_subject, :physics).id.to_s,
          subordinate_subject_id: find_or_create(:secondary_subject, :design_and_technology).id.to_s,
        )
      end

      it "proceeds to design technology specialisms page" do
        expect(wizard).to have_next_step(:design_technology_specialisms)
      end
    end

    context "when no further specialism pages apply" do
      before do
        state_store.write(secondary_master_subject_id: find_or_create(:secondary_subject, :physics).id.to_s)
      end

      it "proceeds to age range page" do
        expect(wizard).to have_next_step(:age_range)
      end
    end
  end

  context "from modern languages specialisms" do
    let(:current_step) { :modern_languages_specialisms }

    before do
      state_store.write(level: "secondary", is_send: false)
    end

    context "when design and technology is selected" do
      before do
        state_store.write(
          secondary_master_subject_id: find_or_create(:secondary_subject, :modern_languages).id.to_s,
          subordinate_subject_id: find_or_create(:secondary_subject, :design_and_technology).id.to_s,
        )
      end

      it "proceeds to design technology specialisms page" do
        expect(wizard).to have_next_step(:design_technology_specialisms)
      end
    end

    context "when no further specialism pages apply" do
      before do
        state_store.write(secondary_master_subject_id: find_or_create(:secondary_subject, :modern_languages).id.to_s)
      end

      it "proceeds to age range page" do
        expect(wizard).to have_next_step(:age_range)
      end
    end
  end

  context "from design technology specialisms" do
    let(:current_step) { :design_technology_specialisms }

    it "proceeds to age range page" do
      expect(wizard).to have_next_step(:age_range)
    end
  end

  context "from age range with primary level" do
    let(:current_step) { :age_range }

    before do
      state_store.write(level: "primary")
    end

    it "proceeds to qualifications page" do
      expect(wizard).to have_next_step(:qualifications)
    end
  end

  context "from age range with secondary level" do
    let(:current_step) { :age_range }

    before do
      state_store.write(level: "secondary")
    end

    it "proceeds to qualifications page" do
      expect(wizard).to have_next_step(:qualifications)
    end
  end

  context "from qualifications with primary level" do
    let(:current_step) { :qualifications }

    before do
      state_store.write(level: "primary")
    end

    it "proceeds to primary subjects page" do
      expect(wizard).to have_next_step(:funding_type)
    end
  end

  context "from qualifications with secondary level" do
    let(:current_step) { :qualifications }

    before do
      state_store.write(level: "secondary")
    end

    it "proceeds to primary subjects page" do
      expect(wizard).to have_next_step(:funding_type)
    end
  end

  context "from qualifications with further education level" do
    let(:current_step) { :qualifications }

    before do
      state_store.write(level: "further_education")
    end

    it "proceeds to funding type page" do
      expect(wizard).to have_next_step(:funding_type)
    end
  end

  context "from qualifications with undergraduate degree with QTS" do
    let(:current_step) { :qualifications }

    before do
      state_store.write(qualification: "undergraduate_degree_with_qts")
    end

    it "proceeds to schools page" do
      expect(wizard).to have_next_step(:schools)
    end
  end

  context "from funding type" do
    let(:current_step) { :funding_type }

    it "proceeds to study pattern page" do
      expect(wizard).to have_next_step(:study_pattern)
    end
  end

  context "from study pattern" do
    let(:current_step) { :study_pattern }

    it "proceeds to schools page" do
      expect(wizard).to have_next_step(:schools)
    end
  end

  context "from schools" do
    let(:current_step) { :schools }

    it "proceeds to study sites page" do
      expect(wizard).to have_next_step(:study_sites)
    end

    context "when provider has no study sites and multiple accredited partners" do
      let!(:provider) do
        school_provider = create(:provider, provider_type: :lead_school, provider_code:, recruitment_cycle:)
        create(:provider_partnership, training_provider: school_provider, accredited_provider: create(:accredited_provider, recruitment_cycle:))
        create(:provider_partnership, training_provider: school_provider, accredited_provider: create(:accredited_provider, recruitment_cycle:))
        school_provider
      end

      it "skips study sites and proceeds to accredited provider page" do
        expect(wizard).to have_next_step(:accredited_provider)
      end
    end
  end

  context "from study sites" do
    let(:current_step) { :study_sites }

    it "proceeds to visa sponsorship page by default" do
      expect(wizard).to have_next_step(:visa_sponsorship)
    end

    context "when qualification is undergraduate degree with qts" do
      before do
        state_store.write(qualification: "undergraduate_degree_with_qts")
      end

      it "proceeds to start date page" do
        expect(wizard).to have_next_step(:start_date)
      end
    end

    context "when qualification is undergraduate degree with qts and provider has multiple accredited partners" do
      let!(:provider) do
        school_provider = create(:provider, provider_type: :lead_school, provider_code:, recruitment_cycle:)
        create(:site, :study_site, provider: school_provider)
        create(:provider_partnership, training_provider: school_provider, accredited_provider: create(:accredited_provider, recruitment_cycle:))
        create(:provider_partnership, training_provider: school_provider, accredited_provider: create(:accredited_provider, recruitment_cycle:))
        school_provider
      end

      before do
        state_store.write(qualification: "undergraduate_degree_with_qts")
      end

      it "proceeds to accredited provider page" do
        expect(wizard).to have_next_step(:accredited_provider)
      end
    end

    context "when level is further education" do
      before do
        state_store.write(level: "further_education")
      end

      it "proceeds to start date page" do
        expect(wizard).to have_next_step(:start_date)
      end
    end

    context "when provider has multiple accredited partners" do
      let!(:provider) do
        school_provider = create(:provider, provider_type: :lead_school, provider_code:, recruitment_cycle:)
        create(:site, :study_site, provider: school_provider)
        create(:provider_partnership, training_provider: school_provider, accredited_provider: create(:accredited_provider, recruitment_cycle:))
        create(:provider_partnership, training_provider: school_provider, accredited_provider: create(:accredited_provider, recruitment_cycle:))
        school_provider
      end

      it "proceeds to accredited provider page" do
        expect(wizard).to have_next_step(:accredited_provider)
      end
    end

    context "when funding type is salary" do
      before do
        state_store.write(funding_type: "salary")
      end

      it "proceeds to skilled worker visa page" do
        expect(wizard).to have_next_step(:skilled_worker_visa)
      end
    end

    context "when funding type is apprenticeship" do
      before do
        state_store.write(funding_type: "apprenticeship")
      end

      it "proceeds to skilled worker visa page" do
        expect(wizard).to have_next_step(:skilled_worker_visa)
      end
    end

    context "when funding type is fee" do
      before do
        state_store.write(funding_type: "fee")
      end

      it "proceeds to visa sponsorship page" do
        expect(wizard).to have_next_step(:visa_sponsorship)
      end
    end
  end

  context "from accredited provider" do
    let(:current_step) { :accredited_provider }

    it "proceeds to start date page for undergraduate degree with qts when funding type is not set" do
      state_store.write(qualification: "undergraduate_degree_with_qts")
      expect(wizard).to have_next_step(:start_date)
    end

    it "proceeds to start date page for undergraduate degree with qts even when funding type is set" do
      state_store.write(qualification: "undergraduate_degree_with_qts")
      state_store.write(funding_type: "salary")
      expect(wizard).to have_next_step(:start_date)
    end

    it "proceeds to visa sponsorship page when fee based course" do
      state_store.write(funding_type: "fee")
      expect(wizard).to have_next_step(:visa_sponsorship)
    end

    it "proceeds to skilled worker visa page when salary based course" do
      state_store.write(funding_type: "salary")
      expect(wizard).to have_next_step(:skilled_worker_visa)
    end

    it "proceeds to skilled worker visa page when apprenticeship based course" do
      state_store.write(funding_type: "apprenticeship")
      expect(wizard).to have_next_step(:skilled_worker_visa)
    end
  end

  context "from start date" do
    let(:current_step) { :start_date }

    it "proceeds to courses page" do
      expect(wizard).to have_next_step(:courses_index)
    end
  end

  context "from visa sponsorship when visa sponsorship is required" do
    let(:current_step) { :visa_sponsorship }

    before do
      state_store.write(can_sponsor_student_visa: true)
    end

    it "proceeds to visa sponsorship application deadline required page" do
      expect(wizard).to have_next_step(:visa_sponsorship_application_deadline_required)
    end
  end

  context "from visa sponsorship when visa sponsorship is not required" do
    let(:current_step) { :visa_sponsorship }

    before do
      state_store.write(can_sponsor_student_visa: false)
    end

    it "proceeds to start date page" do
      expect(wizard).to have_next_step(:start_date)
    end
  end

  context "from skilled worker visa when funding type is salary and can sponsor skilled worker visa is true" do
    let(:current_step) { :skilled_worker_visa }

    before do
      state_store.write(funding_type: "salary")
      state_store.write(can_sponsor_skilled_worker_visa: true)
    end

    it "proceeds to visa sponsorship application deadline required page" do
      expect(wizard).to have_next_step(:visa_sponsorship_application_deadline_required)
    end
  end

  context "from skilled worker visa when funding type is apprenticeship and can sponsor skilled worker visa is false" do
    let(:current_step) { :skilled_worker_visa }

    before do
      state_store.write(funding_type: "apprenticeship")
      state_store.write(can_sponsor_skilled_worker_visa: false)
    end

    it "proceeds to start date page" do
      expect(wizard).to have_next_step(:start_date)
    end
  end

  context "from visa sponsorship application deadline required" do
    let(:current_step) { :visa_sponsorship_application_deadline_required }

    it "proceeds to courses page when deadline for application visa sponsorship is required" do
      state_store.write(visa_sponsorship_application_deadline_required: true)
      expect(wizard).to have_next_step(:visa_sponsorship_application_deadline_at)
    end

    it "proceeds to start date page when deadline for application visa sponsorship is not required" do
      state_store.write(visa_sponsorship_application_deadline_required: false)
      expect(wizard).to have_next_step(:start_date)
    end
  end

  context "from visa sponsorship application deadline at" do
    let(:current_step) { :visa_sponsorship_application_deadline_at }

    it "proceeds to start date page" do
      expect(wizard).to have_next_step(:start_date)
    end
  end
end
