module API
  module Public
    module V1
      class SerializableCourse < JSONAPI::Serializable::Resource
        COURSE_STATE_MAPPING = {
          published_with_unpublished_changes: :published,
        }.freeze

        class << self
          def enrichment_attribute(name, enrichment_name = name)
            attribute name do
              @object.latest_published_enrichment&.public_send(enrichment_name)
            end
          end
        end

        type "courses"

        belongs_to :accredited_body do
          data { @object.accrediting_provider }
        end

        belongs_to :provider
        belongs_to :recruitment_cycle

        attributes :accredited_body_code,
          :age_maximum,
          :age_minimum,
          :bursary_amount,
          :bursary_requirements,
          :created_at,
          :funding_type,
          :gcse_subjects_required,
          :level,
          :name,
          :program_type,
          :qualifications,
          :scholarship_amount,
          :study_mode,
          :uuid,
          :degree_grade,
          :degree_subject_requirements,
          :accept_pending_gcse,
          :accept_gcse_equivalency,
          :accept_english_gcse_equivalency,
          :accept_maths_gcse_equivalency,
          :accept_science_gcse_equivalency,
          :additional_gcse_equivalencies,
          :can_sponsor_skilled_worker_visa,
          :can_sponsor_student_visa

        attribute :about_accredited_body do
          @object.accrediting_provider_description
        end

        attribute :applications_open_from do
          @object.applications_open_from&.iso8601
        end

        attribute :changed_at do
          @object.changed_at&.iso8601
        end

        attribute :code do
          @object.course_code
        end

        attribute :created_at do
          @object.created_at&.iso8601
        end

        attribute :findable do
          @object.findable?
        end

        attribute :has_early_career_payments do
          @object.has_early_career_payments?
        end

        attribute :has_scholarship do
          @object.has_scholarship?
        end

        attribute :has_vacancies do
          @object.has_vacancies?
        end

        attribute :is_send do
          @object.is_send?
        end

        attribute :last_published_at do
          @object.last_published_at&.iso8601
        end

        attribute :open_for_applications do
          @object.open_for_applications?
        end

        attribute :required_qualifications_english do
          @object.english
        end

        attribute :required_qualifications_maths do
          @object.maths
        end

        attribute :required_qualifications_science do
          @object.science
        end

        attribute :running do
          @object.findable?
        end

        attribute :start_date do
          @object.start_date&.strftime("%B %Y")
        end

        attribute :state do
          COURSE_STATE_MAPPING[@object.content_status] || @object.content_status
        end

        attribute :summary do
          @object.description
        end

        attribute :subject_codes do
          @object.subjects.pluck(:subject_code).compact
        end

        attribute :required_qualifications do
          @object.required_qualifications
        end

        enrichment_attribute :about_course
        enrichment_attribute :course_length
        enrichment_attribute :fee_details
        enrichment_attribute :fee_international
        enrichment_attribute :fee_domestic, :fee_uk_eu
        enrichment_attribute :financial_support
        enrichment_attribute :how_school_placements_work
        enrichment_attribute :interview_process
        enrichment_attribute :other_requirements
        enrichment_attribute :personal_qualities
        enrichment_attribute :salary_details
      end
    end
  end
end
