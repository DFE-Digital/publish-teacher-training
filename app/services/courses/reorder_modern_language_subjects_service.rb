# frozen_string_literal: true

module Courses
  class ReorderModernLanguageSubjectsService
    include ServicePattern

    def initialize(course:)
      @course = course
    end

    def call
      return unless modern_languages_course?
      return unless needs_reordering?

      reorder_subjects
    end

  private

    attr_reader :course

    def modern_languages_course?
      course.master_subject_id == modern_languages_id
    end

    def needs_reordering?
      has_nil_positions? || non_language_before_language?
    end

    def has_nil_positions?
      course_subjects.any? { |cs| cs.position.nil? }
    end

    def non_language_before_language?
      return false if language_course_subjects.empty? || non_language_course_subjects.empty?

      lang_min = language_course_subjects.filter_map(&:position).min
      non_lang_min = non_language_course_subjects.filter_map(&:position).min

      lang_min && non_lang_min && non_lang_min < lang_min
    end

    def reorder_subjects
      ordered = ml_course_subjects + language_course_subjects + non_language_course_subjects

      ordered.each_with_index do |cs, index|
        cs.update_column(:position, index)
      end
    end

    def course_subjects
      @course_subjects ||= course.course_subjects.includes(:subject).to_a
    end

    def ml_course_subjects
      @ml_course_subjects ||= course_subjects.select { |cs| cs.subject_id == modern_languages_id }
    end

    def language_course_subjects
      @language_course_subjects ||= course_subjects.select { |cs| cs.subject.is_a?(ModernLanguagesSubject) }
    end

    def non_language_course_subjects
      @non_language_course_subjects ||= course_subjects.reject { |cs| cs.subject_id == modern_languages_id || cs.subject.is_a?(ModernLanguagesSubject) }
    end

    def modern_languages_id
      @modern_languages_id ||= SecondarySubject.modern_languages.id
    end
  end
end
