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

class SecondarySubject < Subject
  def self.modern_languages
    @modern_languages ||= find_by(subject_name: "Modern Languages")
  end

  def self.clear_modern_languages_cache
    @modern_languages = nil
  end
end
