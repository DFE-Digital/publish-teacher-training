# == Schema Information
#
# Table name: ucas_subject
#
#  id           :bigint           not null, primary key
#  type         :text
#  subject_code :text
#  subject_name :text
#

require "rails_helper"

RSpec.describe UCASSubjectSerializer do
  let(:subject_object) { create :ucas_subject }
  subject { serialize(subject_object) }

  it { is_expected.to include(subject_name: subject_object.subject_name, subject_code: subject_object.subject_code) }
end
