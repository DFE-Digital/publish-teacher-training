# frozen_string_literal: true

require "rails_helper"

RSpec.describe CourseWizard::Review do
  subject(:review) { described_class.new(wizard) }

  let(:provider) { instance_double(Provider, study_sites: []) }
  let(:route_strategy) { instance_double(DfE::Wizard::RouteStrategy::DynamicRoutes) }
  let(:providers_relation) { instance_double(ActiveRecord::Relation) }
  let(:recruitment_cycle) { instance_double(RecruitmentCycle, providers: providers_relation) }
  let(:state_store) do
    double(
      "CourseWizard::StateStore",
      qualification: nil,
      funding_type: nil,
      course_age_range_in_years_other_from: "14",
      course_age_range_in_years_other_to: "19",
    )
  end
  let(:wizard) do
    instance_double(
      CourseWizard,
      state_store:,
      recruitment_cycle:,
      route_strategy:,
      provider:,
      provider_code: "ABC",
      recruitment_cycle_year: 2026,
    )
  end

  describe "#format_value" do
    it "renders level option labels" do
      expect(review.format_value(:level, "secondary")).to eq("Secondary")
    end

    it "renders SEND yes/no labels" do
      expect(review.format_value(:is_send, true)).to eq("Yes")
      expect(review.format_value(:is_send, false)).to eq("No")
    end

    it "renders qualification option labels instead of raw values" do
      expect(review.format_value(:qualification, "pgce_with_qts")).to eq("QTS with PGCE")
    end

    it "renders funding type option labels instead of raw values" do
      expect(review.format_value(:funding_type, "fee")).to eq("Fee - no salary")
    end

    it "defaults blank funding type for TDA" do
      allow(state_store).to receive(:qualification).and_return("undergraduate_degree_with_qts")

      expect(review.format_value(:funding_type, nil)).to eq("Salary (apprenticeship)")
    end

    it "renders apprenticeship funding type with check answers wording" do
      expect(review.format_value(:funding_type, "apprenticeship")).to eq("Salary (apprenticeship)")
    end

    it "renders preset age range values in readable format" do
      expect(review.format_value(:age_range_in_years, "14_to_19")).to eq("14 to 19")
    end

    it "renders custom age range values using translation format" do
      expect(review.format_value(:age_range_in_years, "other")).to eq("14 to 19")
    end

    it "returns raw age range key when custom range bounds are missing" do
      allow(state_store).to receive(:course_age_range_in_years_other_from).and_return(nil)

      expect(review.format_value(:age_range_in_years, "other")).to eq("other")
    end

    it "returns nil for blank age range value" do
      expect(review.format_value(:age_range_in_years, nil)).to be_nil
    end

    it "renders sponsor labels for both visa fields" do
      expect(review.format_value(:can_sponsor_student_visa, true)).to eq("Yes - can sponsor")
      expect(review.format_value(:can_sponsor_student_visa, false)).to eq("No - cannot sponsor")
      expect(review.format_value(:can_sponsor_skilled_worker_visa, true)).to eq("Yes - can sponsor")
      expect(review.format_value(:can_sponsor_skilled_worker_visa, false)).to eq("No - cannot sponsor")
    end

    it "renders yes/no for sponsorship deadline required" do
      expect(review.format_value(:visa_sponsorship_application_deadline_required, true)).to eq("Yes")
      expect(review.format_value(:visa_sponsorship_application_deadline_required, false)).to eq("No")
    end

    it "returns subjects as-is" do
      subjects = %w[Physics Mathematics]

      expect(review.format_value(:subjects, subjects)).to eq(subjects)
    end

    it "renders yes/no for engineers teach physics" do
      expect(review.format_value(:engineers_teach_physics, true)).to eq("Yes")
      expect(review.format_value(:engineers_teach_physics, false)).to eq("No")
    end

    it "maps selected subject ids to names" do
      allow(Subject).to receive(:find_by).with(id: "123").and_return(instance_double(Subject, subject_name: "Physics"))

      expect(review.format_value(:secondary_master_subject_id, "123")).to eq("Physics")
    end

    it "returns nil for unknown subject id" do
      allow(Subject).to receive(:find_by).with(id: "999").and_return(nil)

      expect(review.format_value(:primary_master_subject_id, "999")).to be_nil
    end

    it "renders both study patterns using legacy combined wording" do
      expect(review.format_value(:study_pattern, ["", "full_time", "part_time"])).to eq("Full time or part time")
    end

    it "renders a single study pattern label" do
      expect(review.format_value(:study_pattern, %w[full_time])).to eq("Full time")
    end

    it "defaults study pattern for TDA when none selected" do
      allow(state_store).to receive(:qualification).and_return("undergraduate_degree_with_qts")

      expect(review.format_value(:study_pattern, [])).to eq("Full time")
    end

    it "renders placement schools on separate lines" do
      allow(Site).to receive(:where).with(id: %w[1 2]).and_return(
        [
          instance_double(Site, id: 1, location_name: "School one"),
          instance_double(Site, id: 2, location_name: "School two"),
        ],
      )

      expect(review.format_value(:site_ids, %w[1 2])).to eq("School one<br>School two")
    end

    it "renders study sites comma-separated" do
      allow(Site).to receive(:where).with(id: %w[1 2]).and_return(
        [
          instance_double(Site, id: 1, location_name: "Site one"),
          instance_double(Site, id: 2, location_name: "Site two"),
        ],
      )

      expect(review.format_value(:study_sites_ids, %w[1 2])).to eq("Site one, Site two")
    end

    it "maps accredited provider code to provider name" do
      allow(providers_relation).to receive(:find_by).with(provider_code: "ABC").and_return(instance_double(Provider, provider_name: "Provider A"))

      expect(review.format_value(:accredited_provider_code, "ABC")).to eq("Provider A")
    end

    it "returns nil for unknown accredited provider" do
      allow(providers_relation).to receive(:find_by).with(provider_code: "ZZZ").and_return(nil)

      expect(review.format_value(:accredited_provider_code, "ZZZ")).to be_nil
    end

    it "formats visa sponsorship deadline from Date" do
      date = Date.new(2026, 3, 1)

      expect(review.format_value(:visa_sponsorship_application_deadline_at, date)).to eq(date.to_fs(:govuk_date))
    end

    it "formats visa sponsorship deadline from DateParts" do
      parts = CourseWizard::Steps::VisaSponsorshipApplicationDeadlineAt::DateParts.new("2026", "3", "1")

      expect(review.format_value(:visa_sponsorship_application_deadline_at, parts)).to eq(Date.new(2026, 3, 1).to_fs(:govuk_date))
    end

    it "formats visa sponsorship deadline from hash" do
      value = { year: "2026", month: "3", day: "1" }

      expect(review.format_value(:visa_sponsorship_application_deadline_at, value)).to eq(Date.new(2026, 3, 1).to_fs(:govuk_date))
    end

    it "returns nil for blank visa sponsorship deadline" do
      expect(review.format_value(:visa_sponsorship_application_deadline_at, nil)).to be_nil
    end

    it "returns nil for invalid visa sponsorship deadline hash" do
      value = { year: "2026", month: "2", day: "31" }

      expect(review.format_value(:visa_sponsorship_application_deadline_at, value)).to be_nil
    end

    it "returns unhandled attributes unchanged" do
      expect(review.format_value(:start_date, "September 2026")).to eq("September 2026")
    end
  end

  describe "subject id selection for review" do
    let(:state_store) do
      double(
        "CourseWizard::StateStore",
        qualification: nil,
        course_age_range_in_years_other_from: "14",
        course_age_range_in_years_other_to: "19",
        primary_master_subject_id: nil,
        secondary_master_subject_id: "100",
        subordinate_subject_id: "200",
        language_ids: %w[300],
        design_technology_ids: %w[400],
        modern_languages_specialisms?: modern_languages_specialisms,
        design_technology_specialisms?: design_technology_specialisms,
      )
    end

    let(:modern_languages_specialisms) { false }
    let(:design_technology_specialisms) { false }

    it "does not include stale specialism subject ids when specialisms are no longer selected" do
      expect(review.send(:selected_subject_ids)).to eq(%w[100 200])
    end

    context "when modern languages specialism is selected" do
      let(:modern_languages_specialisms) { true }

      it "includes language ids" do
        expect(review.send(:selected_subject_ids)).to eq(%w[100 200 300])
      end
    end

    context "when design technology specialism is selected" do
      let(:design_technology_specialisms) { true }

      it "includes design technology ids" do
        expect(review.send(:selected_subject_ids)).to eq(%w[100 200 400])
      end
    end
  end

  describe "school labels for review" do
    it "uses placement schools label for unsalaried courses" do
      allow(state_store).to receive(:funding_type).and_return("fee")

      expect(review.send(:school_label_with_plural, count: 2)).to eq("Placement schools")
    end

    it "uses employing schools label for salaried courses" do
      allow(state_store).to receive(:funding_type).and_return("salary")

      expect(review.send(:school_label_with_plural, count: 2)).to eq("Employing schools")
    end

    it "uses employing schools label for TDA courses" do
      allow(state_store).to receive_messages(funding_type: nil, qualification: "undergraduate_degree_with_qts")

      expect(review.send(:school_label_with_plural, count: 1)).to eq("Employing school")
    end
  end

  describe "skilled worker visa row visibility" do
    it "shows the row for apprenticeship funding and defaults to cannot sponsor" do
      allow(state_store).to receive(:funding_type).and_return("apprenticeship")

      expect(review.send(:show_skilled_worker_visa_row?)).to be(true)
      expect(review.format_value(:can_sponsor_skilled_worker_visa, nil)).to eq("No - cannot sponsor")
    end

    it "shows the row for TDA courses even when funding type is blank" do
      allow(state_store).to receive_messages(funding_type: nil, qualification: "undergraduate_degree_with_qts")

      expect(review.send(:show_skilled_worker_visa_row?)).to be(true)
    end

    it "hides the row for fee-funded courses" do
      allow(state_store).to receive(:funding_type).and_return("fee")

      expect(review.send(:show_skilled_worker_visa_row?)).to be(false)
    end
  end

  describe "study sites row rendering" do
    before do
      allow(state_store).to receive(:study_sites_ids).and_return([])
    end

    it "shows select study site link when provider has study sites but none selected" do
      allow(provider).to receive(:study_sites).and_return([instance_double(Site, id: 1)])
      allow(route_strategy).to receive(:resolve).with(step_id: :study_sites, options: { return_to_review: :study_sites }).and_return("/wizard/study-sites")

      row = review.send(:row_for_study_sites)

      expect(row.formatted_value).to include("Select a study site")
      expect(row.formatted_value).to include("/wizard/study-sites")
      expect(row.change_path).to be_nil
    end

    it "shows add study site link when provider has no study sites and none selected" do
      allow(provider).to receive(:study_sites).and_return([])
      allow(Rails.application.routes.url_helpers).to receive(:publish_provider_recruitment_cycle_study_sites_path)
        .with("ABC", 2026)
        .and_return("/publish/ABC/2026/study-sites")

      row = review.send(:row_for_study_sites)

      expect(row.formatted_value).to include("Add a study site")
      expect(row.formatted_value).to include("/publish/ABC/2026/study-sites")
      expect(row.change_path).to be_nil
    end
  end
end
