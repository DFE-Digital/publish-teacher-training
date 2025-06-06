# frozen_string_literal: true

require "rails_helper"

RSpec.describe Program do
  describe ".from_type" do
    it "returns a HigherEducationProgramme instance when given :higher_education_programme" do
      expect(described_class.from_type(:higher_education_programme)).to be(HigherEducationProgramme)
    end

    it "returns a HigherEducationSalariedProgramme instance when given :higher_education_salaried_programme" do
      expect(described_class.from_type(:higher_education_salaried_programme)).to be(HigherEducationSalariedProgramme)
    end

    it "returns a SchoolDirectTrainingProgramme instance when given :school_direct_training_programme" do
      expect(described_class.from_type(:school_direct_training_programme)).to be(SchoolDirectTrainingProgramme)
    end

    it "returns a SchoolDirectSalariedTrainingProgramme instance when given :school_direct_salaried_training_programme" do
      expect(described_class.from_type(:school_direct_salaried_training_programme)).to be(SchoolDirectSalariedTrainingProgramme)
    end

    it "returns a SCITTProgramme instance when given :scitt_programme" do
      expect(described_class.from_type(:scitt_programme)).to be(SCITTProgramme)
    end

    it "returns a SCITTSalariedProgramme instance when given :scitt_salaried_programme" do
      expect(described_class.from_type(:scitt_salaried_programme)).to be(SCITTSalariedProgramme)
    end

    it "returns a PostgraduateTeachingApprenticeship instance when given :postgraduate_teaching_apprenticeship" do
      expect(described_class.from_type(:pg_teaching_apprenticeship)).to be(PostgraduateTeachingApprenticeship)
    end

    it "returns a TeacherDegreeApprenticeship instance when given :teacher_degree_apprenticeship" do
      expect(described_class.from_type(:teacher_degree_apprenticeship)).to be(TeacherDegreeApprenticeship)
    end

    it "returns nil when given an unknown type" do
      expect(described_class.from_type(:unknown)).to be(UnknownProgramme)
    end
  end

  describe ".fee_based?" do
    it 'returns true when funding_type is "fee"' do
      allow(described_class).to receive(:funding_type).and_return(ActiveSupport::StringInquirer.new("fee"))
      expect(described_class).to be_fee_based
    end

    it 'returns false when funding_type is not "fee"' do
      allow(described_class).to receive(:funding_type).and_return(ActiveSupport::StringInquirer.new("salary"))
      expect(described_class).not_to be_fee_based
    end
  end

  describe ".where_funding_types" do
    it "returns an array of program keys with the given funding types" do
      expect(described_class.where_funding_types("fee")).to match_array(%i[higher_education_programme school_direct_training_programme scitt_programme])
      expect(described_class.where_funding_types(%w[fee])).to match_array(%i[higher_education_programme school_direct_training_programme scitt_programme])
    end
  end

  describe ".sponsors_student_visa?" do
    it { expect(described_class.sponsors_student_visa?).to be_falsey }
  end

  describe ".sponsors_skilled_worker_visa?" do
    it { expect(described_class.sponsors_skilled_worker_visa?).to be_falsey }
  end

  describe ".where_salaried" do
    it 'returns an array of program keys with funding types "salary" or "apprenticeship"' do
      expect(described_class.where_salaried).to match_array(%i[higher_education_salaried_programme school_direct_salaried_training_programme scitt_salaried_programme pg_teaching_apprenticeship teacher_degree_apprenticeship])
    end
  end

  describe ".where_sponsor_student_visa" do
    it "returns an array of program keys that sponsor student visas" do
      expect(described_class.where_sponsor_student_visa).to match_array(%i[higher_education_programme school_direct_training_programme scitt_programme])
    end
  end

  describe ".where_sponsor_skilled_worker_visa" do
    it "returns an array of program keys that sponsor skilled worker visas" do
      expect(described_class.where_sponsor_skilled_worker_visa).to match_array(%i[school_direct_salaried_training_programme pg_teaching_apprenticeship])
    end
  end

  describe ".visa_type" do
    it "returns student when the funding_type is fee" do
      allow(described_class).to receive(:funding_type).and_return(ActiveSupport::StringInquirer.new("fee"))

      expect(described_class.visa_type).to eq("student")
    end

    it "returns skilled_worker when the funding_type is salary" do
      allow(described_class).to receive(:funding_type).and_return(ActiveSupport::StringInquirer.new("salary"))

      expect(described_class.visa_type).to eq("skilled_worker")
    end

    it "returns skilled_worker when the funding_type is apprenticeship" do
      allow(described_class).to receive(:funding_type).and_return(ActiveSupport::StringInquirer.new("apprenticeship"))

      expect(described_class.visa_type).to eq("skilled_worker")
    end
  end

  describe ".student_visa?" do
    it "returns true when visa_type is student" do
      allow(described_class).to receive(:visa_type).and_return(ActiveSupport::StringInquirer.new("student"))

      expect(described_class).to be_student_visa
    end
  end
end
