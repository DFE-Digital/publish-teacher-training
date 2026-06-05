# frozen_string_literal: true

require "rails_helper"

RSpec.describe "CourseWizard#previous_step", type: :wizard do
  include_context "add_course_wizard"

  context "from level" do
    let(:current_step) { :level }

    it "has no previous step" do
      expect(wizard).to have_previous_step(nil)
    end
  end

  context "from primary subjects" do
    let(:current_step) { :primary_subjects }

    before do
      state_store.write(level: "primary")
    end

    it "goes back to level" do
      expect(wizard).to have_previous_step(:level)
    end
  end

  context "from secondary subjects" do
    let(:current_step) { :secondary_subjects }

    it "goes back to level" do
      expect(wizard).to have_previous_step(:level)
    end
  end

  context "from age range with primary level" do
    let(:current_step) { :age_range }

    before do
      state_store.write(primary_master_subject_id: "123")
      state_store.write(level: "primary")
    end

    it "goes back to primary subjects" do
      expect(wizard).to have_previous_step(:primary_subjects)
    end
  end

  context "from age range with secondary level" do
    let(:current_step) { :age_range }

    before do
      state_store.write(level: "secondary")
      state_store.write(secondary_master_subject_id: "123", subordinate_subject_id: "456")
    end

    it "goes back to secondary subjects" do
      expect(wizard).to have_previous_step(:secondary_subjects)
    end
  end

  context "from age range with secondary level when primary and secondary subjects are both present" do
    let(:current_step) { :age_range }

    before do
      state_store.write(level: "secondary")
      state_store.write(primary_master_subject_id: "123")
      state_store.write(secondary_master_subject_id: "456", subordinate_subject_id: "789")
    end

    it "goes back to secondary subjects" do
      expect(wizard).to have_previous_step(:secondary_subjects)
    end
  end

  context "from qualifications with primary level" do
    let(:current_step) { :qualifications }

    before do
      state_store.write(level: "primary")
    end

    it "goes back to age range" do
      expect(wizard).to have_previous_step(:age_range)
    end
  end

  context "from qualifications with secondary level" do
    let(:current_step) { :qualifications }

    before do
      state_store.write(level: "secondary")
    end

    it "goes back to age range" do
      expect(wizard).to have_previous_step(:age_range)
    end
  end

  context "from qualifications with further education level" do
    let(:current_step) { :qualifications }

    before do
      state_store.write(level: "further_education")
    end

    it "goes back to level" do
      expect(wizard).to have_previous_step(:level)
    end
  end

  context "from funding type" do
    let(:current_step) { :funding_type }

    it "goes back to qualifications" do
      expect(wizard).to have_previous_step(:qualifications)
    end
  end

  context "from study pattern" do
    let(:current_step) { :study_pattern }

    it "goes back to funding type" do
      expect(wizard).to have_previous_step(:funding_type)
    end
  end

  context "from schools" do
    let(:current_step) { :schools }

    it "goes back to study pattern" do
      expect(wizard).to have_previous_step(:study_pattern)
    end
  end

  context "from schools with undergraduate degree with QTS qualification" do
    let(:current_step) { :schools }

    before do
      state_store.write(qualification: "undergraduate_degree_with_qts")
    end

    it "goes back to qualifications" do
      expect(wizard).to have_previous_step(:qualifications)
    end
  end

  context "from study sites" do
    let(:current_step) { :study_sites }

    it "goes back to schools" do
      expect(wizard).to have_previous_step(:schools)
    end
  end

  context "from start date with undergraduate degree with QTS qualification" do
    let(:current_step) { :start_date }

    before do
      state_store.write(qualification: "undergraduate_degree_with_qts")
    end

    it "goes back to study sites" do
      expect(wizard).to have_previous_step(:study_sites)
    end
  end

  context "from start date with further education level" do
    let(:current_step) { :start_date }

    before do
      state_store.write(level: "further_education")
    end

    it "goes back to study sites" do
      expect(wizard).to have_previous_step(:study_sites)
    end
  end

  context "from visa sponsorship" do
    let(:current_step) { :visa_sponsorship }

    it "goes back to study sites" do
      expect(wizard).to have_previous_step(:study_sites)
    end

    context "when provider has multiple accredited partners" do
      let!(:provider) do
        school_provider = create(:provider, provider_type: :lead_school, provider_code:, recruitment_cycle:)
        create(:site, :study_site, provider: school_provider)
        create(:provider_partnership, training_provider: school_provider, accredited_provider: create(:accredited_provider, recruitment_cycle:))
        create(:provider_partnership, training_provider: school_provider, accredited_provider: create(:accredited_provider, recruitment_cycle:))
        school_provider
      end

      it "goes back to accredited provider when fee based course" do
        state_store.write(funding_type: "fee")
        expect(wizard).to have_previous_step(:accredited_provider)
      end
    end
  end

  context "from skilled worker visa" do
    let(:current_step) { :skilled_worker_visa }

    before do
      state_store.write(funding_type: "salary")
    end

    it "goes back to study sites" do
      expect(wizard).to have_previous_step(:study_sites)
    end

    context "when provider has multiple accredited partners" do
      let!(:provider) do
        school_provider = create(:provider, provider_type: :lead_school, provider_code:, recruitment_cycle:)
        create(:site, :study_site, provider: school_provider)
        create(:provider_partnership, training_provider: school_provider, accredited_provider: create(:accredited_provider, recruitment_cycle:))
        create(:provider_partnership, training_provider: school_provider, accredited_provider: create(:accredited_provider, recruitment_cycle:))
        school_provider
      end

      it "goes back to accredited provider when provider has multiple accredited partners" do
        expect(wizard).to have_previous_step(:accredited_provider)
      end
    end
  end

  context "from accredited provider" do
    let(:current_step) { :accredited_provider }
    let!(:provider) do
      school_provider = create(:provider, provider_type: :lead_school, provider_code:, recruitment_cycle:)
      create(:site, :study_site, provider: school_provider)
      create(:provider_partnership, training_provider: school_provider, accredited_provider: create(:accredited_provider, recruitment_cycle:))
      create(:provider_partnership, training_provider: school_provider, accredited_provider: create(:accredited_provider, recruitment_cycle:))
      school_provider
    end

    it "goes back to study sites" do
      expect(wizard).to have_previous_step(:study_sites)
    end
  end
end
