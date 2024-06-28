# frozen_string_literal: true

module ALevelSteps
  class WhatALevelIsRequired < DfE::Wizard::Step
    MAXIMUM_GRADE_CHARACTERS = 50
    attr_accessor :subject, :other_subject, :minimum_grade_required
    attr_writer :uuid

    Subject = Struct.new(:name, keyword_init: true)

    validates :subject, presence: true
    validates :other_subject, presence: true, if: -> { subject == 'other_subject' }
    validates :minimum_grade_required, chars_count: { maximum: MAXIMUM_GRADE_CHARACTERS }, allow_blank: true

    def self.permitted_params
      %i[uuid subject other_subject minimum_grade_required]
    end

    def subjects_list
      A_AND_AS_LEVEL_SUBJECTS.map { |name| Subject.new(name:) }
    end

    def uuid
      @uuid ||= SecureRandom.uuid
    end

    def next_step
      :add_a_level_to_a_list
    end
  end
end
