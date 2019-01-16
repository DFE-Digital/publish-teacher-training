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
#

require 'rails_helper'

RSpec.describe Course, type: :model do
  subject { create(:course) }

  describe 'associations' do
    it { should belong_to(:provider) }
    it { should belong_to(:accrediting_provider) }
    it { should have_and_belong_to_many(:subjects) }
  end
end
