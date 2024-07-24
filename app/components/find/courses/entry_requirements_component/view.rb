# frozen_string_literal: true

module Find
  module Courses
    module EntryRequirementsComponent
      class View < ViewComponent::Base
        include PreviewHelper

        attr_accessor :course

        SUBJECT_KNOWLEDGE_ENHANCEMENTS_SUBJECT_CODES = %w[F1 11 G1 F3 15 17 22 24].freeze

        def initialize(course:)
          super
          @course = course
        end

        def qualification_required
          if course.teacher_degree_apprenticeship?
            t('.a_levels')
          else
            t('.degree')
          end
        end

        private

        def subject_knowledge_enhancement_content?
          if course.subjects.first.subject_code.nil?
            course.subjects.any? { |subject| SUBJECT_KNOWLEDGE_ENHANCEMENTS_SUBJECT_CODES.include?(subject.subject_code) }
          else
            SUBJECT_KNOWLEDGE_ENHANCEMENTS_SUBJECT_CODES.include?(course.subjects.first.subject_code)
          end
        end

        def required_gcse_content(course)
          case course.level
          when 'primary'
            "Grade #{course.gcse_grade_required} (C) in English, maths and science"
          when 'secondary'
            "Grade #{course.gcse_grade_required} (C) in English and maths"
          end
        end

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
