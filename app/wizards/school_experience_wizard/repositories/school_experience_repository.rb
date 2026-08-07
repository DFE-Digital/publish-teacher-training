# frozen_string_literal: true

class SchoolExperienceWizard
  module Repositories
    class SchoolExperienceRepository < DfE::Wizard::Repository::Model
      SCHOOL_EXPERIENCE_ATTRIBUTES = %i[
        school_experience_required
        school_experience_required_content
      ].freeze

      def readable_attributes
        SCHOOL_EXPERIENCE_ATTRIBUTES
      end

      def writable_attributes
        SCHOOL_EXPERIENCE_ATTRIBUTES
      end

      def write_data(hash)
        # The wizard steps validate these values before the repository writes
        # them. Do not run unrelated Course validations here.
        record.assign_attributes(hash.slice(*writable_attributes))
        record.save!(validate: false)
      end

      def transform_for_read(step_data)
        step_data[:experience_required] = step_data[:school_experience_required]

        step_data[:experience_details] = step_data[:school_experience_required_content]

        step_data.deep_symbolize_keys
      end

      def transform_for_write(model_data)
        # A "no" answer on the required step (false) is written straight to the
        # course and clears any content.
        if model_data[:experience_required] == false
          model_data[:school_experience_required] = false
          model_data[:school_experience_required_content] = nil
        end

        # Content arriving on the experience_details step records the "yes"
        # answer (held in the cache until now) and stores the content.
        if model_data[:experience_details].present?
          model_data[:school_experience_required] = true
          model_data[:school_experience_required_content] = model_data[:experience_details]
        end

        model_data
      end
    end
  end
end
