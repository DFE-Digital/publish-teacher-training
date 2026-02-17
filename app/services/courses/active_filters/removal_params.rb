module Courses
  module ActiveFilters
    class RemovalParams
      def initialize(search_params:, attribute:, current_value:, all_values:)
        @search_params = search_params
        @attribute = attribute
        @current_value = current_value
        @all_values = all_values
      end

      def call
        case @attribute
        when :subject_code
          calculate_subject_code_removal
        when :subjects
          calculate_subjects_removal
        when :provider_code
          calculate_provider_code_removal
        else
          calculate_default_removal
        end
      end

    private

      def calculate_subject_code_removal
        cleaned_subjects = subjects_array - [@current_value]

        {
          subject_code: remaining_values.presence,
          subject_name: nil,
          subjects: cleaned_subjects.presence,
        }
      end

      def calculate_subjects_removal
        removal_params = { subjects: remaining_values.presence }

        # If removing a subject that matches subject_code, clear both
        if subject_code_value == @current_value
          removal_params[:subject_code] = nil
          removal_params[:subject_name] = nil
        end

        removal_params
      end

      def calculate_provider_code_removal
        { provider_code: nil, provider_name: nil }
      end

      def calculate_default_removal
        { @attribute => remaining_values.presence }
      end

      def subjects_array
        @subjects_array ||= Array(@search_params[:subjects])
      end

      def subject_code_value
        @search_params[:subject_code]
      end

      def remaining_values
        Array(@all_values) - [@current_value]
      end
    end
  end
end
