#  Does the subject list mention languages but hasn't already been covered?
module Subjects
  class MFLOtherMapping
    def applicable_to?(ucas_subjects)
      (ucas_subjects & language_categories).any? &&
        (ucas_subjects & mandarin).none? &&
        (ucas_subjects & mfl_main).none?
    end

    def to_s
      "Modern languages (other)"
    end

  private

    def language_categories
      ["languages", "languages (african)", "languages (asian)", "languages (european)"]
    end

    def mandarin
      %w[chinese mandarin]
    end

    def mfl_main
      ["english as a second or other language",
       "french",
       "german",
       "italian",
       "japanese",
       "russian",
       "spanish"]
    end
  end
end
