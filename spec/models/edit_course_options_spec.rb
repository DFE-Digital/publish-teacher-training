require 'rails_helper'

RSpec.describe EditCourseOptions, type: :model do
  let(:course) { create(:course, name: 'Biology', course_code: '3X9F') }
  let(:edit_course_options) { EditCourseOptions.new(course) }

  context 'entry_requirements' do
    it 'returns the entry requirements that users can choose between' do
      expect(edit_course_options.entry_requirements).to eq(%i[must_have_qualification_at_application_time expect_to_achieve_before_training_begins equivalence_test])
    end
  end
end
