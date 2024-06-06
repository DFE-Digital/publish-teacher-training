# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Program do
  describe '.from_type' do
    it 'returns a HigherEducationProgramme instance when given :higher_education_programme' do
      expect(Program.from_type(:higher_education_programme)).to be(HigherEducationProgramme)
    end

    it 'returns a HigherEducationSalariedProgramme instance when given :higher_education_salaried_programme' do
      expect(Program.from_type(:higher_education_salaried_programme)).to be(HigherEducationSalariedProgramme)
    end

    it 'returns a SchoolDirectTrainingProgramme instance when given :school_direct_training_programme' do
      expect(Program.from_type(:school_direct_training_programme)).to be(SchoolDirectTrainingProgramme)
    end

    it 'returns a SchoolDirectSalariedTrainingProgramme instance when given :school_direct_salaried_training_programme' do
      expect(Program.from_type(:school_direct_salaried_training_programme)).to be(SchoolDirectSalariedTrainingProgramme)
    end

    it 'returns a SCITTProgramme instance when given :scitt_programme' do
      expect(Program.from_type(:scitt_programme)).to be(SCITTProgramme)
    end

    it 'returns a SCITTSalariedProgramme instance when given :scitt_salaried_programme' do
      expect(Program.from_type(:scitt_salaried_programme)).to be(SCITTSalariedProgramme)
    end

    it 'returns a PostgraduateTeachingApprenticeship instance when given :postgraduate_teaching_apprenticeship' do
      expect(Program.from_type(:pg_teaching_apprenticeship)).to be(PostgraduateTeachingApprenticeship)
    end

    it 'returns a TeacherDegreeApprenticeship instance when given :teacher_degree_apprenticeship' do
      expect(Program.from_type(:teacher_degree_apprenticeship)).to be(TeacherDegreeApprenticeship)
    end

    it 'returns nil when given an unknown type' do
      expect(Program.from_type(:unknown)).to be(UnknownProgramme)
    end
  end

  describe '.fee_funded?' do
    it 'returns true when funding_type is "fee"' do
      allow(Program).to receive(:funding_type).and_return(ActiveSupport::StringInquirer.new('fee'))
      expect(Program).to be_fee_based
    end

    it 'returns false when funding_type is not "fee"' do
      allow(Program).to receive(:funding_type).and_return(ActiveSupport::StringInquirer.new('salary'))
      expect(Program).not_to be_fee_based
    end
  end
end

RSpec.describe HigherEducationProgramme do
  describe '.funding_type' do
    it 'returns an ActiveSupport::StringInquirer' do
      expect(HigherEducationProgramme.funding_type).to be_a(ActiveSupport::StringInquirer)
    end

    it 'returns "fee"' do
      expect(HigherEducationProgramme.funding_type).to eq('fee')
    end

    it 'responds to fee?' do
      expect(HigherEducationProgramme.funding_type).to be_fee
    end
  end
end

RSpec.describe HigherEducationSalariedProgramme do
  describe '.funding_type' do
    it 'returns an ActiveSupport::StringInquirer' do
      expect(HigherEducationSalariedProgramme.funding_type).to be_a(ActiveSupport::StringInquirer)
    end

    it 'returns "salary"' do
      expect(HigherEducationSalariedProgramme.funding_type).to eq('salary')
    end

    it 'responds to salary?' do
      expect(HigherEducationSalariedProgramme.funding_type).to be_salary
    end
  end
end

RSpec.describe SchoolDirectTrainingProgramme do
  describe '.funding_type' do
    it 'returns an ActiveSupport::StringInquirer' do
      expect(SchoolDirectTrainingProgramme.funding_type).to be_a(ActiveSupport::StringInquirer)
    end

    it 'returns "fee"' do
      expect(SchoolDirectTrainingProgramme.funding_type).to eq('fee')
    end

    it 'responds to fee?' do
      expect(SchoolDirectTrainingProgramme.funding_type).to be_fee
    end
  end
end

RSpec.describe SchoolDirectSalariedTrainingProgramme do
  describe '.funding_type' do
    it 'returns an ActiveSupport::StringInquirer' do
      expect(SchoolDirectSalariedTrainingProgramme.funding_type).to be_a(ActiveSupport::StringInquirer)
    end

    it 'returns "salary"' do
      expect(SchoolDirectSalariedTrainingProgramme.funding_type).to eq('salary')
    end

    it 'responds to salary?' do
      expect(SchoolDirectSalariedTrainingProgramme.funding_type).to be_salary
    end
  end
end

RSpec.describe SCITTProgramme do
  describe '.funding_type' do
    it 'returns an ActiveSupport::StringInquirer' do
      expect(SCITTProgramme.funding_type).to be_a(ActiveSupport::StringInquirer)
    end

    it 'returns "fee"' do
      expect(SCITTProgramme.funding_type).to eq('fee')
    end

    it 'responds to fee?' do
      expect(SCITTProgramme.funding_type).to be_fee
    end
  end
end

RSpec.describe SCITTSalariedProgramme do
  describe '.funding_type' do
    it 'returns an ActiveSupport::StringInquirer' do
      expect(SCITTSalariedProgramme.funding_type).to be_a(ActiveSupport::StringInquirer)
    end

    it 'returns "salary"' do
      expect(SCITTSalariedProgramme.funding_type).to eq('salary')
    end

    it 'responds to salary?' do
      expect(SCITTSalariedProgramme.funding_type).to be_salary
    end
  end
  end

RSpec.describe PostgraduateTeachingApprenticeship do
  describe '.funding_type' do
    it 'returns an ActiveSupport::StringInquirer' do
      expect(PostgraduateTeachingApprenticeship.funding_type).to be_a(ActiveSupport::StringInquirer)
    end

    it 'returns "apprenticeship"' do
      expect(PostgraduateTeachingApprenticeship.funding_type).to eq('apprenticeship')
    end

    it 'responds to apprenticeship?' do
      expect(PostgraduateTeachingApprenticeship.funding_type).to be_apprenticeship
    end
  end
end

RSpec.describe TeacherDegreeApprenticeship do
  describe '.funding_type' do
    it 'returns an ActiveSupport::StringInquirer' do
      expect(TeacherDegreeApprenticeship.funding_type).to be_a(ActiveSupport::StringInquirer)
    end

    it 'returns "apprenticeship"' do
      expect(TeacherDegreeApprenticeship.funding_type).to eq('apprenticeship')
    end

    it 'responds to apprenticeship?' do
      expect(TeacherDegreeApprenticeship.funding_type).to be_apprenticeship
    end
  end
end
