# frozen_string_literal: true

module Publish
  module SubjectHelper
    def primary_form_options(subjects = primary_subjects)
      subjects.map do |subject|
        PrimarySubjectInput.new(subject.id, subject.subject_name)
      end
    end

    private

    PrimarySubjectInput = Struct.new(:id, :name)

    def primary_subjects
      Subject.where(type: 'PrimarySubject')
             .order(:subject_name)
    end
  end
end
