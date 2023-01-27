# frozen_string_literal: true

module Find
  class SubjectsForm
    include ActiveModel::Model

    attr_reader :subjects, :age_group

    def initialize(subjects:, age_group:)
      @subjects = subjects
      @age_group = age_group
    end

    validate :subjects_have_been_selected

    def subjects_have_been_selected
      errors.add(:subjects, :"#{age_group}_subject") if subjects.blank? && age_group.present?
    end

    def primary?
      age_group == 'primary'
    end

    def secondary?
      age_group == 'secondary'
    end
  end
end
