# frozen_string_literal: true

class SchoolExperienceWizard
  module Repositories
    class SchoolExperienceRepository < DfE::Wizard::Repository::Model
      def transform_for_read(step_data)
        step_data.deep_symbolize_keys
      end

      def transform_for_write(model_data)
        model_data
      end
    end
  end
end
