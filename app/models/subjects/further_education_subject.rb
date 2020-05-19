class FurtherEducationSubject < Subject
  def self.instance
    find_by(subject_name: "Further education")
  end
end
