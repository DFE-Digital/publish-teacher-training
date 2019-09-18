# == Schema Information
#
# Table name: subject
#
#  id           :integer          not null, primary key
#  subject_name :text
#  subject_code :text             not null
#

require "rails_helper"

RSpec.describe SubjectSerializer do
  let(:subject_object) { create :subject }
  subject { serialize(subject_object) }

  it { is_expected.to include(subject_name: subject_object.subject_name, subject_code: subject_object.subject_code) }
end
