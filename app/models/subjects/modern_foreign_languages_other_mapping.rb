# Does the subject list mention languages but hasn't already been covered?
# TODO: this should be replaced with an explicit static mapping
module Subjects
  class ModernForeignLanguagesOtherMapping
    LANGUAGE_CATEGORIES = ["languages", "languages (african)", "languages (asian)", "languages (european)"].freeze
    MAIN_MODERN_FOREIGN_LANGUAGES = [
      "english as a second or other language",
      "french",
      "german",
      "italian",
      "japanese",
      "russian",
      "spanish",
    ].freeze
    MANDARIN_UCAS_SUBJECTS = %w[chinese mandarin].freeze

    def applicable_to?(ucas_subjects)
      language_course?(ucas_subjects) && !mandarin?(ucas_subjects) && !main_mfl?(ucas_subjects)
    end

    def to_s
      "Modern languages (other)"
    end

  private

    def language_course?(ucas_subjects)
      (ucas_subjects & LANGUAGE_CATEGORIES).any?
    end

    def mandarin?(ucas_subjects)
      (ucas_subjects & MANDARIN_UCAS_SUBJECTS).any?
    end

    def main_mfl?(ucas_subjects)
      (ucas_subjects & MAIN_MODERN_FOREIGN_LANGUAGES).any?
    end
  end
end
