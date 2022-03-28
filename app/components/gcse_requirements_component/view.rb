# frozen_string_literal: true

module GcseRequirementsComponent
  class View < ViewComponent::Base
    attr_reader :course, :errors

    def initialize(course:, errors: nil)
      super
      @course = course
      @errors = errors
    end

    def inset_text_css_classes
      messages = errors&.values&.flatten

      if messages&.include?("Enter GCSE requirements")
        "app-inset-text--narrow-border app-inset-text--error"
      else
        "app-inset-text--narrow-border app-inset-text--important"
      end
    end

    def has_errors?
      return unless inset_text_css_classes.include?("app-inset-text--error")
    end

  private

    def required_gcse_summary_content(course)
      case course.level
      when "primary"
        "Grade #{course.gcse_grade_required} (C) or above in English, maths and science, or equivalent qualification"
      when "secondary"
        "Grade #{course.gcse_grade_required} (C) or above in English and maths, or equivalent qualification"
      end
    end

    def required_gcse_content(course)
      case course.level
      when "primary"
        "GCSE grade #{course.gcse_grade_required} (C) or above in English, maths and science, or equivalent qualification."
      when "secondary"
        "GCSE grade #{course.gcse_grade_required} (C) or above in English and maths, or equivalent qualification."
      end
    end

    def pending_gcse_summary_content(course)
      if course.accept_pending_gcse
        "Candidates with pending GCSEs will be considered"
      else
        "Candidates with pending GCSEs will not be considered"
      end
    end

    def pending_gcse_content(course)
      if course.accept_pending_gcse
        "We’ll consider candidates who are currently taking GCSEs."
      else
        "We will not consider candidates with pending GCSEs."
      end
    end

    def gcse_equivalency_summary_content(course)
      if course.accept_gcse_equivalency
        "Equivalency tests will be accepted in #{equivalencies}."
      else
        "Equivalency tests will not be accepted"
      end
    end

    def gcse_equivalency_content(course)
      if course.accept_gcse_equivalency
        "We’ll consider candidates who need to take a GCSE equivalency test in #{equivalencies}."
      else
        "We will not consider candidates who need to take GCSE equivalency tests."
      end
    end

    def equivalencies
      subjects = []
      subjects << "English" if course.accept_english_gcse_equivalency.present?
      subjects << "maths" if course.accept_maths_gcse_equivalency.present?
      subjects << "science" if course.accept_science_gcse_equivalency.present?

      subjects.to_sentence(last_word_connector: " or ", two_words_connector: " or ")
    end
  end
end
