# frozen_string_literal: true

module Publish
  class CourseFundingForm < Form
    alias course model

    FIELDS = %i[
      funding
      funding_type
      can_sponsor_skilled_worker_visa
      can_sponsor_student_visa
      previous_tda_course
    ].freeze

    attr_accessor(*FIELDS)

    validates :funding, presence: true, if: -> { db_backed_funding_type_feature_flag_active? }
    validates :funding_type, presence: true, if: -> { !db_backed_funding_type_feature_flag_active? }
    validates :can_sponsor_skilled_worker_visa, inclusion: { in: [true, false, 'true', 'false'] }, if: -> { skilled_worker_visa? }
    validates :can_sponsor_student_visa, inclusion: { in: [true, false, 'true', 'false'] }, if: -> { student_visa? }

    def initialize(model, params: {})
      super(model, model, params:)

      @funding_updated = if db_backed_funding_type_feature_flag_active?
                           course.funding != compute_fields[:funding]
                         else
                           course.funding_type != compute_fields[:funding_type]
                         end
      origin_step
    end

    def funding_updated?
      @funding_updated
    end

    def origin_step
      @origin_step ||= if funding_updated?
                         if db_backed_funding_type_feature_flag_active?
                           if [course.funding, new_attributes[:funding]].include?('apprenticeship')
                             :apprenticeship
                           else
                             :funding
                           end
                         elsif [course.funding_type, new_attributes[:funding_type]].include?('apprenticeship')
                           :apprenticeship
                         else
                           :funding_type
                         end
                       end
    end

    def is_fee_based?
      if db_backed_funding_type_feature_flag_active?
        funding == 'fee'
      else
        funding_type == 'fee'
      end
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
          financial_support: nil
        },
        student: {
          salary_details: nil
        }
      }[visa_type]
    end

    def reset_course_attributes
      {
        skilled_worker: {
          can_sponsor_student_visa: false
        },
        student: {
          can_sponsor_skilled_worker_visa: false
        }
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

      ::Courses::AssignProgramTypeService.new.execute(course.funding, course) if db_backed_funding_type_feature_flag_active?

      course.save!
    end

    def original_fields_values
      if db_backed_funding_type_feature_flag_active?
        {
          funding: course.funding,
          can_sponsor_skilled_worker_visa: course.can_sponsor_skilled_worker_visa,
          can_sponsor_student_visa: course.can_sponsor_student_visa
        }
      else

        {
          funding_type: course.funding_type,
          can_sponsor_skilled_worker_visa: course.can_sponsor_skilled_worker_visa,
          can_sponsor_student_visa: course.can_sponsor_student_visa
        }
      end
    end

    def compute_fields
      original_fields_values.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end

    def form_store_key
      :funding_types_and_visas
    end

    def db_backed_funding_type_feature_flag_active?
      FeatureService.enabled?(:db_backed_funding_type)
    end
  end
end
