require 'rails_helper'

RSpec.describe EditCourseOptions, type: :model do
  let(:course) { create(:course) }
  let(:edit_course_options) { EditCourseOptions.new(course) }

  context 'entry_requirements' do
    it 'returns the entry requirements that users can choose between' do
      expect(edit_course_options.entry_requirements).to eq(%i[must_have_qualification_at_application_time expect_to_achieve_before_training_begins equivalence_test])
    end
  end

  context 'qualifications' do
    context 'for a course that’s not further education' do
      it 'returns only QTS options for users to choose between' do
        expect(edit_course_options.qualifications).to eq(%w[qts pgce_with_qts pgde_with_qts])
        edit_course_options.qualifications.each do |q|
          expect(q.include?('qts')).to be_truthy
        end
      end
    end

    context 'for a further education course' do
      let(:course) { create(:course, subjects: [build(:further_education_subject)]) }
      it 'returns only QTS options for users to choose between' do
        expect(edit_course_options.qualifications).to eq(%w[pgce pgde])
        edit_course_options.qualifications.each do |q|
          expect(q.include?('qts')).to be_falsy
        end
      end
    end
  end
end
