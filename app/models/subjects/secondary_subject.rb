# frozen_string_literal: true

class SecondarySubject < Subject
  class << self
    def modern_languages
      @modern_languages ||= find_by(subject_name: "Modern Languages")
    end

    def physics
      @physics ||= find_by(subject_name: "Physics")
    end

    def design_technology
      @design_technology ||= find_by(subject_name: "Design and technology")
    end

    def clear_cache
      @modern_languages = nil
      @physics = nil
      @design_technology = nil
    end
  end
end
