# frozen_string_literal: true

require "rails_helper"

RSpec.describe CourseWizard::StateStores::CourseWizardStore do
  subject(:store) { described_class.new(repository:, attribute_names: %w[level qualification can_sponsor_student_visa can_sponsor_skilled_worker_visa funding_type]) }

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
end
