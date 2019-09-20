# == Schema Information
#
# Table name: subject
#
#  id           :bigint           not null, primary key
#  type         :text
#  subject_code :text
#  subject_name :text
#

class SecondarySubject < Subject
  def self.modern_languages
    find_by(subject_name: "Modern Languages")
  end
end
