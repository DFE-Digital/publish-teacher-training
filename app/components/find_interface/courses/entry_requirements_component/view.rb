module FindInterface
  module Courses
    class EntryRequirementsComponent::View < ViewComponent::Base
      attr_accessor :course

      def initialize(course:)
        super
        @course = course
      end

    private

      def degree_grade_content(course)
        degree_grade_hash = {
          "two_one" => "An undergraduate degree at class 2:1 or above, or equivalent.",
          "two_two" => "An undergraduate degree at class 2:2 or above, or equivalent.",
          "third_class" => "An undergraduate degree, or equivalent. This should be an honours degree (Third or above), or equivalent.",
          "not_required" => "An undergraduate degree, or equivalent.",
        }

        degree_grade_hash[course.degree_grade]
      end

      def required_gcse_content(course)
        case course.level
        when "primary"
          "Grade #{course.gcse_grade_required} (C) or above in English, maths and science, or equivalent qualification."
        when "secondary"
          "Grade #{course.gcse_grade_required} (C) or above in English and maths, or equivalent qualification."
        end
      end

      def secondary_advisory(course)
        "Your degree subject should be in #{course.name} or a similar subject. Otherwise you’ll need to prove your subject knowledge in some other way."
      end

      def pending_gcse_content(course)
        if course.accept_pending_gcse
          "We’ll consider candidates with pending GCSEs."
        else
          "We will not consider candidates with pending GCSEs."
        end
      end

      def gcse_equivalency_content(course)
        if course.accept_gcse_equivalency?
          "We’ll consider candidates who need to take a GCSE equivalency test in #{equivalencies}."
        else
          "We will not consider candidates who need to take a GCSE equivalency test."
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
end
