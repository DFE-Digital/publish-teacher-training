module Repositories
  class ALevelRepository < DfE::Wizard::Repository::Model
    attr_reader :virtual_attributes

    VIRTUAL_ATTRIBUTES = %i[
      add_another_a_level
      confirmation
    ].freeze

    def transform_for_read(step_data)
      step_data.merge!(@virtual_attributes || {}).deep_symbolize_keys

      step_data.deep_symbolize_keys
    end

    def transform_for_write(model_data)
      @virtual_attributes = model_data.slice(*VIRTUAL_ATTRIBUTES)

      model_data.except!(*VIRTUAL_ATTRIBUTES)

      model_data
    end

    # Avoid mixing up the Course.uuid and the subject["uuid"]
    def excluded_columns
      [:uuid]
    end
  end
end
