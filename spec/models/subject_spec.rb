# == Schema Information
#
# Table name: subject
#
#  id           :integer          not null, primary key
#  subject_name :text
#  subject_code :text             not null
#

require 'rails_helper'

RSpec.describe Subject, type: :model do
  subject { create(:subject, subject_name: 'Mathematics') }

  it { should have_many(:courses).through(:course_subjects) }
  its(:to_s) { should eq('Mathematics') }
end
