# frozen_string_literal: true

class SchoolExperienceWizard
  module Repositories
    class SchoolExperienceRepository < DfE::Wizard::Repository::Model
      def transform_for_read(step_data)
        step_data[:experience_required] = boolean_to_string(step_data[:school_experience_required])

        step_data[:experience_details] = step_data[:school_experience_required_content]

        step_data.deep_symbolize_keys
      end

      def transform_for_write(model_data)
        if model_data[:experience_required].nil?
          model_data.delete(:experience_required)
          model_data[:school_experience_required_content] = nil
        else
          model_data[:school_experience_required] = string_to_boolean(model_data[:experience_required])
        end

        # If experience isn't required, delete the content
        if model_data[:experience_required] == "no"
          model_data[:school_experience_required_content] = nil
        elsif model_data[:experience_required] == "yes"
          model_data.delete(:experience_details)
        else
          model_data[:school_experience_required_content] = model_data[:experience_details]
        end

        model_data
      end

    private

      def boolean_to_string(value)
        case value
        when true then "yes"
        when false then "no"
        end
      end

      def string_to_boolean(value)
        case value
        when "yes" then true
        when "no" then false
        end
      end
    end
  end
end
