# == Schema Information
#
# Table name: subject
#
#  id           :bigint           not null, primary key
#  subject_code :text
#  subject_name :text
#  type         :text
#
# Indexes
#
#  index_subject_on_subject_name  (subject_name)
#

require "rails_helper"

describe SubjectSerializer do
  let(:subject_object) { create :primary_subject }
  subject { serialize(subject_object, serializer_class: SubjectSerializer) }

  it { is_expected.to include(subject_name: subject_object.subject_name, subject_code: subject_object.subject_code) }
end
