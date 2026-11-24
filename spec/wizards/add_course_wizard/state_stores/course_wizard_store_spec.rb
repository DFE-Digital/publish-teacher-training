# frozen_string_literal: true

require "rails_helper"

RSpec.describe CourseWizard::StateStores::CourseWizardStore do
  subject(:store) { described_class.new(repository:).tap { |store| store.attribute_names = %w[level qualification can_sponsor_student_visa can_sponsor_skilled_worker_visa funding_type visa_sponsorship_application_deadline_required] } }

  let(:repository) { instance_double(DfE::Wizard::Repository::InMemory) }

  describe "#further_education_level?" do
    before do
      allow(repository).to receive(:read).and_return({ level: })
    end

    context "when level is 'further_education'" do
      let(:level) { "further_education" }

      it "returns true" do
        expect(store.further_education_level?).to be true
      end
    end

    context "when level is not 'further_education'" do
      let(:level) { "primary" }

      it "returns false" do
        expect(store.further_education_level?).to be false
      end
    end
  end

  describe "#primary_level?" do
    before do
      allow(repository).to receive(:read).and_return({ level: })
    end

    context "when level is 'primary'" do
      let(:level) { "primary" }

      it "returns true" do
        expect(store.primary_level?).to be true
      end
    end

    context "when level is not 'primary'" do
      let(:level) { "secondary" }

      it "returns false" do
        expect(store.primary_level?).to be false
      end
    end
  end

  describe "#fee_based?" do
    before do
      allow(repository).to receive(:read).and_return({ funding_type: })
    end

    context "when funding type is 'fee'" do
      let(:funding_type) { "fee" }

      it "returns true" do
        expect(store.fee_based?).to be true
      end
    end

    context "when funding type is 'apprenticeship'" do
      let(:funding_type) { "apprenticeship" }

      it "returns false" do
        expect(store.fee_based?).to be false
      end
    end

    context "when funding type is 'salary'" do
      let(:funding_type) { "salary" }

      it "returns false" do
        expect(store.fee_based?).to be false
      end
    end
  end

  describe "#salary_based?" do
    before do
      allow(repository).to receive(:read).and_return({ funding_type: })
    end

    context "when funding type is salary" do
      let(:funding_type) { "salary" }

      it "returns true" do
        expect(store.salary_based?).to be true
      end
    end

    context "when funding type is apprenticeship" do
      let(:funding_type) { "apprenticeship" }

      it "returns true" do
        expect(store.salary_based?).to be true
      end
    end

    context "when funding type is fee" do
      let(:funding_type) { "fee" }

      it "returns false" do
        expect(store.salary_based?).to be false
      end
    end
  end

  describe "#undergraduate_degree_with_qts?" do
    before do
      allow(repository).to receive(:read).and_return({ qualification: })
    end

    context "when qualification is 'undergraduate_degree_with_qts'" do
      let(:qualification) { "undergraduate_degree_with_qts" }

      it "returns true" do
        expect(store.undergraduate_degree_with_qts?).to be true
      end
    end

    context "when qualification is not 'undergraduate_degree_with_qts'" do
      let(:qualification) { "qts" }

      it "returns false" do
        expect(store.undergraduate_degree_with_qts?).to be false
      end
    end
  end

  describe "#visa_sponsorship_required?" do
    before do
      allow(repository).to receive(:read).and_return({ can_sponsor_student_visa: })
    end

    context "when can_sponsor_student_visa is true" do
      let(:can_sponsor_student_visa) { true }

      it "returns true" do
        expect(store.visa_sponsorship_required?).to be true
      end
    end

    context "when can_sponsor_student_visa is false" do
      let(:can_sponsor_student_visa) { false }

      it "returns false" do
        expect(store.visa_sponsorship_required?).to be false
      end
    end

    context "when can_sponsor_student_visa is 'true'" do
      let(:can_sponsor_student_visa) { "true" }

      it "returns true" do
        expect(store.visa_sponsorship_required?).to be true
      end
    end

    context "when can_sponsor_student_visa is 'false'" do
      let(:can_sponsor_student_visa) { "false" }

      it "returns false" do
        expect(store.visa_sponsorship_required?).to be false
      end
    end
  end

  describe "#skilled_worker_visa_sponsorship_required?" do
    before do
      allow(repository).to receive(:read).and_return({ can_sponsor_skilled_worker_visa: })
    end

    context "when can_sponsor_skilled_worker_visa is true" do
      let(:can_sponsor_skilled_worker_visa) { true }

      it "returns true" do
        expect(store.skilled_worker_visa_sponsorship_required?).to be true
      end
    end

    context "when can_sponsor_skilled_worker_visa is false" do
      let(:can_sponsor_skilled_worker_visa) { false }

      it "returns false" do
        expect(store.skilled_worker_visa_sponsorship_required?).to be false
      end
    end

    context "when can_sponsor_skilled_worker_visa is 'true'" do
      let(:can_sponsor_skilled_worker_visa) { "true" }

      it "returns true" do
        expect(store.skilled_worker_visa_sponsorship_required?).to be true
      end
    end

    context "when can_sponsor_skilled_worker_visa is 'false'" do
      let(:can_sponsor_skilled_worker_visa) { "false" }

      it "returns false" do
        expect(store.skilled_worker_visa_sponsorship_required?).to be false
      end
    end
  end

  describe "#deadline_for_application_visa_sponsorship_required?" do
    before do
      allow(repository).to receive(:read).and_return({ visa_sponsorship_application_deadline_required: })
    end

    context "when visa_sponsorship_application_deadline_required is true" do
      let(:visa_sponsorship_application_deadline_required) { true }

      it "returns true" do
        expect(store.deadline_for_application_visa_sponsorship_required?).to be true
      end
    end

    context "when visa_sponsorship_application_deadline_required is false" do
      let(:visa_sponsorship_application_deadline_required) { false }

      it "returns false" do
        expect(store.deadline_for_application_visa_sponsorship_required?).to be false
      end
    end

    context "when visa_sponsorship_application_deadline_required is 'true'" do
      let(:visa_sponsorship_application_deadline_required) { "true" }

      it "returns true" do
        expect(store.deadline_for_application_visa_sponsorship_required?).to be true
      end
    end

    context "when visa_sponsorship_application_deadline_required is 'false'" do
      let(:visa_sponsorship_application_deadline_required) { "false" }

      it "returns false" do
        expect(store.deadline_for_application_visa_sponsorship_required?).to be false
      end
    end
  end

  # The answers as the course takes them, read from the store a wizard builds
  describe "the course's answers" do
    subject(:answers) { wizard.state_store }

    include_context "add_course_wizard"

    context "with a TDA course, which has no funding type, study pattern or skilled worker visa question" do
      before { answers.write(qualification: "undergraduate_degree_with_qts") }

      it "is a full time apprenticeship that cannot sponsor skilled worker visas" do
        expect(answers.tda?).to be(true)
        expect(answers.funding).to eq("apprenticeship")
        expect(answers).to be_employment_based
        expect(answers).not_to be_salary_based
        expect(answers.study_modes).to eq(%w[full_time])
        expect(answers.can_sponsor_skilled_worker_visa_or_default).to be(false)
      end
    end

    context "with any other course" do
      before { answers.write(qualification: "pgce_with_qts") }

      it "takes the funding type, study pattern and skilled worker visa as answered" do
        answers.write(funding_type: "salary", study_pattern: %w[full_time part_time], can_sponsor_skilled_worker_visa: true)

        expect(answers.funding).to eq("salary")
        expect(answers).to be_employment_based
        expect(answers.study_modes).to eq(%w[full_time part_time])
        expect(answers.can_sponsor_skilled_worker_visa_or_default).to be(true)
      end

      it "is not employment based for a fee paying course, with no study modes or skilled worker visa until answered" do
        answers.write(funding_type: "fee")

        expect(answers).not_to be_employment_based
        expect(answers.study_modes).to eq([])
        expect(answers.can_sponsor_skilled_worker_visa_or_default).to be_nil
      end
    end

    it "gives an other age range as its bounds" do
      answers.write(age_range_in_years: "other", course_age_range_in_years_other_from: "14", course_age_range_in_years_other_to: "19")
      expect(answers.age_range).to eq("14_to_19")

      answers.write(course_age_range_in_years_other_to: nil)
      expect(answers.age_range).to eq("other")

      answers.write(age_range_in_years: "11_to_16")
      expect(answers.age_range).to eq("11_to_16")
    end

    it "takes the main subject of the level" do
      answers.write(primary_master_subject_id: "1", secondary_master_subject_id: "2")

      answers.write(level: "primary")
      expect(answers.master_subject_id).to eq("1")
      expect(answers.subject_ids).to eq(%w[1])
      answers.write(level: "secondary")
      expect(answers.master_subject_id).to eq("2")
      answers.write(level: "further_education")
      expect(answers.master_subject_id).to be_nil
      expect(answers.subject_ids).to eq([])
    end

    it "lists the secondary subjects with each one's specialisms below it, only for the specialisms asked" do
      modern_languages = SecondarySubject.modern_languages
      french = find_or_create(:secondary_subject, :french)
      design_technology = SecondarySubject.design_technology
      engineering = find_or_create(:design_technology_subject, :engineering)
      answers.write(
        level: "secondary",
        secondary_master_subject_id: modern_languages.id.to_s,
        subordinate_subject_id: design_technology.id.to_s,
        language_ids: [french.id.to_s],
        design_technology_ids: [engineering.id.to_s],
      )

      expect(answers.subject_ids).to eq([modern_languages.id.to_s, french.id.to_s, design_technology.id.to_s, engineering.id.to_s])

      answers.write(subordinate_subject_id: nil)
      expect(answers.subject_ids).to eq([modern_languages.id.to_s, french.id.to_s])

      answers.write(subordinate_subject_id: modern_languages.id.to_s)
      expect(answers.subject_ids).to eq([modern_languages.id.to_s, french.id.to_s])
    end

    it "drops blank schools and study sites, and has no study sites when the question was not answered" do
      answers.write(school_uuids: ["a", ""], study_sites_ids: ["3", ""])
      expect(answers.selected_school_uuids).to eq(%w[a])
      expect(answers.study_site_ids).to eq(%w[3])

      answers.write(study_sites_ids: nil)
      expect(answers.study_site_ids).to be_nil
    end

    it "reads the visa deadline from its date parts, however they were stored" do
      [
        { "year" => "2028", "month" => "4", "day" => "2" },
        { year: "2028", month: "4", day: "2" },
        CourseWizard::Steps::VisaSponsorshipApplicationDeadlineAt::DateParts.new("2028", "4", "2"),
      ].each do |stored|
        answers.write(visa_sponsorship_application_deadline_at: stored)

        expect([answers.visa_deadline.year, answers.visa_deadline.month, answers.visa_deadline.day]).to eq([2028, 4, 2])
        expect(answers.visa_deadline.to_formatted_string).to eq(Date.new(2028, 4, 2).to_fs(:govuk_date))
      end
    end
  end
end
