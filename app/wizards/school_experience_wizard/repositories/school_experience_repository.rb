# frozen_string_literal: true

class SchoolExperienceWizard
  module Repositories
    class SchoolExperienceRepository < DfE::Wizard::Repository::Model
      def transform_for_read(step_data)
        step_data[:experience_required] = step_data[:school_experience_required]
        step_data.deep_symbolize_keys
      end

      def transform_for_write(model_data)
        # This runs when experience_require is "no" on the required step
        unless model_data[:experience_required].nil?
          model_data[:school_experience_required] = model_data[:experience_required]
        end
        model_data
      end
    end
  end
end
