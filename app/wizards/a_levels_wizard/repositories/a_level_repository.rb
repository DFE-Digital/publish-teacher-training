class ALevelsWizard
  module Repositories
    class ALevelRepository < DfE::Wizard::Repository::Model
      attr_reader :virtual_attributes

      VIRTUAL_ATTRIBUTES = %i[
        add_another_a_level
        confirmation
      ].freeze

      def transform_for_read(step_data)
        step_data.merge!(@virtual_attributes || {}).deep_symbolize_keys

        step_data[:pending_a_level] = boolean_to_string(step_data[:accept_pending_a_level])
        step_data[:accept_a_level_equivalency] = boolean_to_string(step_data[:accept_a_level_equivalency])

        step_data.deep_symbolize_keys
      end

      def transform_for_write(model_data)
        @virtual_attributes = model_data.slice(*VIRTUAL_ATTRIBUTES)

        model_data.except!(*VIRTUAL_ATTRIBUTES)

        if model_data[:pending_a_level].nil?
          model_data.delete(:pending_a_level)
        else
          model_data[:accept_pending_a_level] = string_to_boolean(model_data.delete(:pending_a_level))
        end

        if model_data[:accept_a_level_equivalency].nil?
          model_data.delete(:accept_a_level_equivalency)
        else
          model_data[:accept_a_level_equivalency] = string_to_boolean(model_data[:accept_a_level_equivalency])
        end

        model_data
      end

      # Avoid mixing up the Course.uuid and the subject["uuid"]
      def excluded_columns
        [:uuid]
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
