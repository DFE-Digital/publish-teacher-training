# == Schema Information
#
# Table name: subject
#
#  created_at      :datetime
#  id              :bigint           not null, primary key
#  subject_area_id :bigint
#  subject_code    :text
#  subject_name    :text
#  type            :text
#  updated_at      :datetime
#
# Indexes
#
#  index_subject_on_subject_area_id  (subject_area_id)
#  index_subject_on_subject_name     (subject_name)
#

class DiscontinuedSubject < Subject
end
