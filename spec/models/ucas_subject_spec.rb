# == Schema Information
#
# Table name: subject
#
#  id           :integer          not null, primary key
#  subject_name :text
#  subject_code :text             not null
#

require 'rails_helper'

RSpec.describe UCASSubject, type: :model do
  subject { find_or_create(:subject, :mathematics) }

  it { should have_many(:courses).through(:course_subjects) }
  its(:to_s) { should eq('Mathematics') }
end
