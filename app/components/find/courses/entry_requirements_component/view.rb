# frozen_string_literal: true

module Find
  module Courses
    module EntryRequirementsComponent
      class View < ViewComponent::Base
        attr_accessor :course

        SUBJECT_KNOWLEDGE_ENHANCEMENTS_SUBJECT_CODES = %w[C1 F1 11 DT Q3 G1 F3 V6 15 17 22].freeze
        PRIMARY_WITH_MATHEMATICS_SUBJECT_CODES = %w[03].freeze

        def initialize(course:)
          super
          @course = course
        end

        private

        def degree_grade_content(course)
          degree_grade_hash = {
            'two_one' => 'An undergraduate degree at class 2:1 or above, or equivalent.',
            'two_two' => 'An undergraduate degree at class 2:2 or above, or equivalent.',
            'third_class' => 'An undergraduate degree, or equivalent. This should be an honours degree (Third or above), or equivalent.',
            'not_required' => 'An undergraduate degree, or equivalent.'
          }

          degree_grade_hash[course.degree_grade]
        end

        def subject_knowledge_enhancement_content?
          if course.subjects.first.subject_code.nil?
            course.subjects.any? { |subject| SUBJECT_KNOWLEDGE_ENHANCEMENTS_SUBJECT_CODES.include?(subject.subject_code) }
          else
            SUBJECT_KNOWLEDGE_ENHANCEMENTS_SUBJECT_CODES.include?(course.subjects.first.subject_code)
          end
        end

        def primary_with_mathematics_subject?
          PRIMARY_WITH_MATHEMATICS_SUBJECT_CODES.include?(course.subjects.first.subject_code)
        end

        def required_gcse_content(course)
          case course.level
          when 'primary'
            "Grade #{course.gcse_grade_required} (C) or above in English, maths and science, or equivalent qualification."
          when 'secondary'
            "Grade #{course.gcse_grade_required} (C) or above in English and maths, or equivalent qualification."
          end
        end

        # def secondary_advisory(course)
        # "Your degree subject should be in #{course.computed_subject_name_or_names} or a similar subject. Otherwise you’ll need to prove your subject knowledge in some other way."
        #  end

        def pending_gcse_content(course)
          if course.accept_pending_gcse
            'We’ll consider candidates with pending GCSEs.'
          else
            'We will not consider candidates with pending GCSEs.'
          end
        end

        def gcse_equivalency_content(course)
          if course.accept_gcse_equivalency?
            "We’ll consider candidates who need to take a GCSE equivalency test in #{equivalencies}."
          else
            'We will not consider candidates who need to take a GCSE equivalency test.'
          end
        end

        def equivalencies
          subjects = []
          subjects << 'English' if course.accept_english_gcse_equivalency.present?
          subjects << 'maths' if course.accept_maths_gcse_equivalency.present?
          subjects << 'science' if course.accept_science_gcse_equivalency.present?

          subjects.to_sentence(last_word_connector: ' or ', two_words_connector: ' or ')
        end
      end
    end
  end
end
