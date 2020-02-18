module API
  module V3
    class SerializableCourse < JSONAPI::Serializable::Resource
      class << self
        def enrichment_attribute(name, enrichment_name = name)
          attribute name do
            @object.enrichments
              .select(&:published?)
              .max_by { |e| [e.created_at, e.id] }
              &.__send__(enrichment_name)
          end
        end
      end

      type "courses"

      attributes :findable?, :open_for_applications?, :has_vacancies?,
                 :course_code, :name, :study_mode, :qualification, :description,
                 :content_status, :ucas_status, :funding_type,
                 :level, :is_send?, :english, :maths, :science, :gcse_subjects_required,
                 :age_range_in_years, :accrediting_provider,
                 :accrediting_provider_code, :level

      attribute :start_date do
        @object.start_date.strftime("%B %Y") if @object.start_date
      end

      attribute :applications_open_from do
        @object.applications_open_from&.iso8601
      end

      attribute :last_published_at do
        @object.last_published_at&.iso8601
      end

      attribute :about_accrediting_body do
        @object.accrediting_provider_description
      end

      attribute :provider_code do
        @object.provider.provider_code
      end

      attribute :recruitment_cycle_year do
        @object.recruitment_cycle.year
      end

      belongs_to :provider
      belongs_to :accrediting_provider

      has_many :site_statuses
      has_many :sites
      has_many :subjects

      enrichment_attribute :about_course
      enrichment_attribute :course_length
      enrichment_attribute :fee_details
      enrichment_attribute :fee_international
      enrichment_attribute :fee_uk_eu
      enrichment_attribute :financial_support
      enrichment_attribute :how_school_placements_work
      enrichment_attribute :interview_process
      enrichment_attribute :other_requirements
      enrichment_attribute :personal_qualities
      enrichment_attribute :required_qualifications
      enrichment_attribute :salary_details
    end
  end
end
