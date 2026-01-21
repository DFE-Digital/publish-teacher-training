module Repositories
  class ALevelRepository < DfE::Wizard::Repository::Model
    attr_reader :virtual_attributes

    VIRTUAL_ATTRIBUTES = %i[
      add_another_a_level
      confirmation
    ].freeze

    def transform_for_read(data)
      data.merge!(@virtual_attributes || {}).deep_symbolize_keys

      data[:pending_a_level] = data[:accept_pending_a_level]
      data[:subjects] = data[:a_level_subject_requirements]

      data.deep_symbolize_keys
    end

    def transform_for_write(data)
      @virtual_attributes = data.slice(*VIRTUAL_ATTRIBUTES)

      data.except!(*VIRTUAL_ATTRIBUTES)

      data[:accept_pending_a_level] = data[:pending_a_level] unless data[:pending_a_level].nil?

      data
    end

    def excluded_columns
      [:uuid]
    end
  end
end
