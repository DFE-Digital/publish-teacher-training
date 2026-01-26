module Repositories
  class ALevelSubjectRepository < DfE::Wizard::Repository::Model
    attr_reader :uuid

    def initialize(params:, **)
      super(**)

      @uuid = params[:uuid]
    end

    def transform_for_write(data)
      # data may have string or symbol keys depending on the caller
      data = data.with_indifferent_access
      current_array = record.a_level_subject_requirements.dup

      if (index = current_array.find_index { |s| s["uuid"] == data[:uuid] })
        current_array[index] = data.to_h.stringify_keys # Update
      else
        current_array << data.to_h.stringify_keys # Append
      end

      { a_level_subject_requirements: current_array }
    end

    def transform_for_read(_data)
      return {} if uuid.blank?

      record.find_a_level_subject_requirement!(uuid)
    end
  end
end
