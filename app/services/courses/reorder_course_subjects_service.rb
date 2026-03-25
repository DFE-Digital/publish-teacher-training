# frozen_string_literal: true

module Courses
  class ReorderCourseSubjectsService
    include ServicePattern

    PARENT_CHILD_TYPES = {
      "Modern Languages" => "ModernLanguagesSubject",
      "Design and technology" => "DesignTechnologySubject",
    }.freeze

    def initialize(course:)
      @course = course
    end

    def call
      return if course.master_subject_id.nil?
      return if course_subjects.empty?

      reorder_subjects
    end

  private

    attr_reader :course

    def reorder_subjects
      ordered = build_ordered_list

      ordered.each_with_index do |cs, index|
        cs.update_column(:position, index) if cs.position != index
      end
    end

    def build_ordered_list
      master_group = subject_group_for(course.master_subject_id)
      remaining = remaining_course_subjects(master_group)

      # Group remaining subjects: if any are parents with children, keep them together
      grouped_remaining = group_remaining_subjects(remaining)

      master_group + grouped_remaining
    end

    # Returns an ordered array: [parent_course_subject, *child_course_subjects]
    # If the subject has no children, returns just [course_subject]
    def subject_group_for(subject_id)
      return [] if subject_id.nil?

      parent_cs = course_subjects.find { |cs| cs.subject_id == subject_id }
      return [] unless parent_cs

      child_type = PARENT_CHILD_TYPES[subjects_by_id[subject_id]&.subject_name]

      if child_type
        children = course_subjects
          .select { |cs| cs.subject_id != subject_id && subjects_by_id[cs.subject_id]&.type == child_type }
          .sort_by { |cs| cs.position || Float::INFINITY }
        [parent_cs, *children]
      else
        [parent_cs]
      end
    end

    def remaining_course_subjects(master_group)
      master_ids = master_group.map(&:id).to_set

      course_subjects
        .reject { |cs| master_ids.include?(cs.id) }
        .sort_by { |cs| cs.position || Float::INFINITY }
    end

    # Among the remaining subjects, find any parent-child relationships and group them.
    # Process parents first so children are grouped under them regardless of current position.
    def group_remaining_subjects(remaining)
      parents, others = remaining.partition { |cs| PARENT_CHILD_TYPES.key?(subjects_by_id[cs.subject_id]&.subject_name) }

      result = []
      used_ids = Set.new

      parents.each do |cs|
        child_type = PARENT_CHILD_TYPES[subjects_by_id[cs.subject_id]&.subject_name]
        children = others.select { |r| !used_ids.include?(r.id) && subjects_by_id[r.subject_id]&.type == child_type }

        result << cs
        used_ids.add(cs.id)
        children.each do |c|
          result << c
          used_ids.add(c.id)
        end
      end

      others.each do |cs|
        next if used_ids.include?(cs.id)

        result << cs
        used_ids.add(cs.id)
      end

      result
    end

    def course_subjects
      @course_subjects ||= course.course_subjects.reload.includes(:subject).to_a
    end

    def subjects_by_id
      @subjects_by_id ||= course_subjects.each_with_object({}) { |cs, h| h[cs.subject_id] = cs.subject }
    end
  end
end
