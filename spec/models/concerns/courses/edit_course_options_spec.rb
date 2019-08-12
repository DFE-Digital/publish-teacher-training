require 'rails_helper'

RSpec.describe Course, type: :model do
  let(:course) { create(:course, subjects: [subjects]) }
  let(:subjects) { create(:subject, :primary) }

  context 'entry_requirements' do
    it 'returns the entry requirements that users can choose between' do
      expect(course.entry_requirements).to eq(%i[must_have_qualification_at_application_time expect_to_achieve_before_training_begins equivalence_test])
    end
  end

  context 'qualifications' do
    context 'for a course that’s not further education' do
      it 'returns only QTS options for users to choose between' do
        expect(course.qualification_options(course)).to eq(%w[qts pgce_with_qts pgde_with_qts])
        course.qualification_options(course).each do |q|
          expect(q.include?('qts')).to be_truthy
        end
      end
    end

    context 'for a further education course' do
      let(:subjects) { create(:further_education_subject) }
      it 'returns only QTS options for users to choose between' do
        expect(course.qualification_options(course)).to eq(%w[pgce pgde])
        course.qualification_options(course).each do |q|
          expect(q.include?('qts')).to be_falsy
        end
      end
    end
  end

  context 'age_range' do
    context 'for primary' do
      it 'returns the correct ages range for users to co choose between' do
        expect(course.age_range_options(course)).to eq(%w[3_to_7 5_to_11 7_to_11 7_to_14])
      end
    end

    context 'for secondary' do
      let(:subjects) { create(:subject, :secondary) }
      it 'returns the correct age ranges for users to co choose between' do
        expect(course.age_range_options(course)).to eq(%w[11_to_16 11_to_18 14_to_19])
      end
    end
  end

  context 'start_date_options' do
    let(:recruitment_year) { course.provider.recruitment_cycle.year.to_i }

    it 'should return the correct options for the recruitment_cycle' do
      expect(course.start_date_options(course)).to eq(
        ["August #{recruitment_year}",
         "September #{recruitment_year}",
         "October #{recruitment_year}",
         "November #{recruitment_year}",
         "December #{recruitment_year}",
         "January #{recruitment_year + 1}",
         "February #{recruitment_year + 1}",
         "March #{recruitment_year + 1}",
         "April #{recruitment_year + 1}",
         "May #{recruitment_year + 1}",
         "June #{recruitment_year + 1}",
         "July #{recruitment_year + 1}"]
     )
    end
  end
end
