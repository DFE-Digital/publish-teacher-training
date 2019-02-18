# == Schema Information
#
# Table name: course
#
#  id                      :integer          not null, primary key
#  age_range               :text
#  course_code             :text
#  name                    :text
#  profpost_flag           :text
#  program_type            :text
#  qualification           :integer          not null
#  start_date              :datetime
#  study_mode              :text
#  accrediting_provider_id :integer
#  provider_id             :integer          default(0), not null
#  modular                 :text
#  english                 :integer
#  maths                   :integer
#  science                 :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

require 'rails_helper'

RSpec.describe Course, type: :model do
  subject { create(:course) }

  describe 'associations' do
    it { should belong_to(:provider) }
    it { should belong_to(:accrediting_provider).optional }
    it { should have_and_belong_to_many(:subjects) }
  end

  describe '#changed_since' do
    let!(:old_course) { create(:course, age: 1.hour.ago) }
    let!(:course) { create(:course, age: 1.hour.ago) }

    context 'with no parameters' do
      subject { Course.changed_since(nil) }
      it { should include course }
      it { should include old_course }
    end

    context 'with a course that was just updated' do
      before { course.touch }

      subject { Course.changed_since(10.minutes.ago) }

      it { should include course }
      it { should_not include old_course }
    end

    context 'when the checked timestamp matches the course updated_at' do
      subject { Course.changed_since(course.updated_at) }

      it { should include course }
    end
  end
end
