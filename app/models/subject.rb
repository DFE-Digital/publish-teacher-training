# == Schema Information
#
# Table name: subject
#
#  id           :integer          not null, primary key
#  subject_name :text
#  subject_code :text             not null
#

class Subject < ApplicationRecord
  scope :further_education, -> { where(subject_name: 'Further Education') }
end
