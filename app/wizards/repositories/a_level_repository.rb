module Repositories
  class ALevelRepository < DfE::Wizard::Repository::Model
    attr_reader :virtual_attributes

    VIRTUAL_ATTRIBUTES = %i[
      add_another_a_level
      confirmation
    ].freeze

    def transform_for_read(data)
      data.merge!(@virtual_attributes || {}).deep_symbolize_keys

      data[:pending_a_level] = boolean_to_string(data[:accept_pending_a_level])
      data[:accept_a_level_equivalency] = boolean_to_string(data[:accept_a_level_equivalency])
      data[:subjects] = data[:a_level_subject_requirements]

      data.deep_symbolize_keys
    end

    def transform_for_write(data)
      @virtual_attributes = data.slice(*VIRTUAL_ATTRIBUTES)

      data.except!(*VIRTUAL_ATTRIBUTES)

      if data[:pending_a_level].nil?
        data.delete(:pending_a_level)
      else
        data[:accept_pending_a_level] = string_to_boolean(data.delete(:pending_a_level))
      end

      if data[:accept_a_level_equivalency].nil?
        data.delete(:accept_a_level_equivalency)
      else
        data[:accept_a_level_equivalency] = string_to_boolean(data[:accept_a_level_equivalency])
      end

      data
    end

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
