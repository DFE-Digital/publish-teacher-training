# frozen_string_literal: true

module Publish
  class CourseFundingForm < Form
    alias_method :course, :model

    FIELDS = %i[
      funding
      funding_type
      can_sponsor_skilled_worker_visa
      can_sponsor_student_visa
      previous_tda_course
      visa_sponsorship_application_deadline_at
    ].freeze

    attr_accessor(*FIELDS)

    validates :funding, presence: true
    validates :can_sponsor_skilled_worker_visa, inclusion: { in: [true, false, "true", "false"] }, if: -> { skilled_worker_visa? }
    validates :can_sponsor_student_visa, inclusion: { in: [true, false, "true", "false"] }, if: -> { student_visa? }

    def initialize(model, params: {})
      super(model, model, params:)

      @funding_updated = course.funding != compute_fields[:funding]
      origin_step
    end

    def funding_updated?
      @funding_updated
    end

    def origin_step
      @origin_step ||= if funding_updated?
                         if [course.funding, new_attributes[:funding]].include?("apprenticeship")
                           :apprenticeship
                         else
                           :funding
                         end
                       end
    end

    def is_fee_based?
      funding == "fee"
    end

    def visa_type
      is_fee_based? ? :student : :skilled_worker
    end

    def student_visa?
      visa_type == :student
    end

    def skilled_worker_visa?
      visa_type == :skilled_worker
    end

    def fields_to_ignore_before_save
      super + [:previous_tda_course]
    end

  private

    def reset_enrichment_attributes
      {
        skilled_worker: {
          fee_details: nil,
          fee_international: nil,
          fee_uk_eu: nil,
          financial_support: nil,
        },
        student: {
          salary_details: nil,
        },
      }[visa_type]
    end

    def reset_course_attributes
      {
        skilled_worker: {
          can_sponsor_student_visa: false,
        },
        student: {
          can_sponsor_skilled_worker_visa: false,
        },
      }[visa_type]
    end

    def after_save
      return unless funding_updated?

      enrichment = course.enrichments.find_or_initialize_draft

      if enrichment.persisted?
        enrichment.assign_attributes(reset_enrichment_attributes)

        enrichment.save!
      end

      course.assign_attributes(reset_course_attributes)

      ::Courses::AssignProgramTypeService.new.execute(course.funding, course)

      course.save!
    end

    def original_fields_values
      {
        funding: course.funding,
        can_sponsor_skilled_worker_visa: course.can_sponsor_skilled_worker_visa,
        can_sponsor_student_visa: course.can_sponsor_student_visa,
      }
    end

    def assign_attributes_to_model
      self.fields = compute_fields
      super
    end

    def compute_fields
      computed = original_fields_values.symbolize_keys.slice(*FIELDS).merge(new_attributes)
      computed[:visa_sponsorship_application_deadline_at] = nil if cannot_sponsor_visas?(computed)

      computed
    end

    def cannot_sponsor_visas?(computed)
      (skilled_worker_visa? && computed[:can_sponsor_skilled_worker_visa].in?(["false", false])) ||
        (student_visa? && computed[:can_sponsor_student_visa].in?(["false", false]))
    end

    def form_store_key
      :funding_types_and_visas
    end
  end
end
