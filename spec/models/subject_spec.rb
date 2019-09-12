# == Schema Information
#
# Table name: subject
#
#  id           :bigint           not null, primary key
#  type         :text
#  subject_code :text
#  subject_name :text
#

require 'rails_helper'

describe Subject, type: :model do
  subject { find_or_create(:subject, subject_name: 'Modern languages (other)') }

  it { should have_many(:courses).through(:course_subjects) }
  its(:to_sym) { should eq(:modern_languages_other) }
end
