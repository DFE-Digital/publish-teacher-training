class ALevelsWizard
  module Repositories
    class ALevelSubjectRemoval < DfE::Wizard::Repository::Model
      attr_reader :uuid

      def initialize(uuid:, **)
        super(**)

        @uuid = uuid
      end

      def transform_for_write(step_data)
        return {} unless step_data[:confirmation] == "yes"

        updated_subjects = record.a_level_subject_requirements.reject { |s| s["uuid"] == uuid }

        if updated_subjects.empty?
          {
            a_level_subject_requirements: [],
            accept_pending_a_level: nil,
            accept_a_level_equivalency: nil,
            additional_a_level_equivalencies: nil,
          }
        else
          { a_level_subject_requirements: updated_subjects }
        end
      end

      def transform_for_read(_data)
        {}
      end
    end
  end
end
