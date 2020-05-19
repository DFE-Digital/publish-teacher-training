class SecondarySubject < Subject
  def self.modern_languages
    @modern_languages ||= find_by(subject_name: "Modern Languages")
  end

  def self.clear_modern_languages_cache
    @modern_languages = nil
  end
end
