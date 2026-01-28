module Repositories
  class ALevelSubjectRemovalRepository < DfE::Wizard::Repository::Model
    attr_reader :uuid

    def initialize(params:, **)
      super(**)

      @uuid = params[:uuid]
    end

    def transform_for_write(data)
      return {} unless data[:confirmation] == "yes"

      updated_subjects = record.a_level_subject_requirements.reject { |s| s["uuid"] == uuid }
      { a_level_subject_requirements: updated_subjects }
    end

    def transform_for_read(_data)
      {}
    end
  end
end
