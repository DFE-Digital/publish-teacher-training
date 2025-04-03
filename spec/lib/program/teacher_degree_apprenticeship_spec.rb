# frozen_string_literal: true

RSpec.describe TeacherDegreeApprenticeship do
  describe ".funding_type" do
    it "returns an ActiveSupport::StringInquirer" do
      expect(described_class.funding_type).to be_a(ActiveSupport::StringInquirer)
    end

    it 'returns "apprenticeship"' do
      expect(described_class.funding_type).to eq("apprenticeship")
    end

    it "responds to apprenticeship?" do
      expect(described_class.funding_type).to be_apprenticeship
    end
  end

  describe ".sponsors_student_visa?" do
    it { expect(described_class).not_to be_sponsors_student_visa }
  end

  describe ".sponsors_skilled_worker_visa?" do
    it { expect(described_class).not_to be_sponsors_skilled_worker_visa }
  end
end
