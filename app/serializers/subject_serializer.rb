# == Schema Information
#
# Table name: subject
#
#  id           :bigint           not null, primary key
#  type         :text
#  subject_code :text
#  subject_name :text
#

class SubjectSerializer < ActiveModel::Serializer
  attributes :subject_name, :subject_code, :type
end
