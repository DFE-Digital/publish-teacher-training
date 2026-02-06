# frozen_string_literal: true

module ALevelSteps
  class WhatALevelIsRequired
    include DfE::Wizard::Step

    MAXIMUM_GRADE_CHARACTERS = 50

    Subject = Struct.new(:name, keyword_init: true)

    attribute :subject, :string
    attribute :other_subject, :string
    attribute :minimum_grade_required, :string
    attribute :uuid, :string, default: -> { SecureRandom.uuid }

    validates :subject, presence: true
    validates :other_subject, presence: true, if: -> { subject == "other_subject" }
    validates :minimum_grade_required, chars_count: { maximum: MAXIMUM_GRADE_CHARACTERS }, allow_blank: true

    def self.permitted_params
      %i[uuid subject other_subject minimum_grade_required]
    end

    def subjects_list
      A_AND_AS_LEVEL_SUBJECTS.map { |name| Subject.new(name:) }
    end
  end
end
