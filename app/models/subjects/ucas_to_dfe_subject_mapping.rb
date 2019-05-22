module Subjects
  class UCASToDFESubjectMapping
    def initialize(ucas_input_subjects_or_options_hash, resulting_dfe_subject)
      if ucas_input_subjects_or_options_hash.is_a?(Array)
        @included_ucas_subjects = ucas_input_subjects_or_options_hash
        @ucas_subjects_match = nil
        @course_title_matches = nil
      elsif ucas_input_subjects_or_options_hash.is_a?(Hash)
        @included_ucas_subjects = ucas_input_subjects_or_options_hash[:ucas_subjects]
        @ucas_subjects_match = ucas_input_subjects_or_options_hash[:ucas_subjects_match]
        @course_title_matches = ucas_input_subjects_or_options_hash[:course_title_matches]
      end

      @resulting_dfe_subject = resulting_dfe_subject
    end

    def applicable_to?(ucas_subjects_to_map, course_title)
      applicable_to_ucas_subjects?(ucas_subjects_to_map) &&
        applicable_to_course_title?(course_title)
    end

    def to_dfe_subject
      @resulting_dfe_subject
    end

  private

    def applicable_to_ucas_subjects?(ucas_subjects_to_map)
      if @included_ucas_subjects
        (ucas_subjects_to_map & @included_ucas_subjects).any?
      else
        @ucas_subjects_match.call(ucas_subjects_to_map)
      end
    end

    def applicable_to_course_title?(course_title)
      @course_title_matches.nil? || @course_title_matches.call(course_title)
    end
  end
end
