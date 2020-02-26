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
#  index_subject_on_subject_code  (subject_code)
#  index_subject_on_subject_name  (subject_name)
#  index_subject_on_type          (type)
#

class SecondarySubject < Subject
  def self.modern_languages
    @modern_languages ||= find_by(subject_name: "Modern Languages")
  end

  def self.clear_modern_languages_cache
    @modern_languages = nil
  end
end
