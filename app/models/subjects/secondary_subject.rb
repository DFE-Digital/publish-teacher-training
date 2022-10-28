class SecondarySubject < Subject
  class << self
    def modern_languages
      @modern_languages ||= find_by(subject_name: "Modern Languages")
    end

    def physics
      @physics ||= find_by(subject_name: "Physics")
    end

    def clear_cache
      @modern_languages = nil
      @physics = nil
    end
  end
end
