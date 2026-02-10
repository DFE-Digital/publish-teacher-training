class ALevelsWizard
  module Repositories
    class ALevelSubjectRepository < DfE::Wizard::Repository::Model
      attr_reader :uuid

      def initialize(uuid:, **)
        super(**)

        @uuid = uuid
      end

      # data is only the attributes defined by the step
      def transform_for_write(step_data)
        # data may have string or symbol keys depending on the caller
        data = step_data.with_indifferent_access

        current_array = record.a_level_subject_requirements.dup

        if (index = current_array.find_index { |s| s["uuid"] == data[:uuid] })
          current_array[index] = data.to_h.stringify_keys # Update
        else
          current_array << data.to_h.stringify_keys # Append
        end

        { a_level_subject_requirements: current_array }
      end

      # data is the repository attributes
      def transform_for_read(_model_data)
        return {} if uuid.blank?

        record.find_a_level_subject_requirement!(uuid)
      end
    end
  end
end
