# == Schema Information
#
# Table name: subject
#
#  id           :integer          not null, primary key
#  subject_name :text
#  subject_code :text             not null
#

class UCASSubjectSerializer < ActiveModel::Serializer
  attributes :subject_name, :subject_code
end
