module API
  module V2
    class SerializableCourse < JSONAPI::Serializable::Resource
      include TimeFormat

      class << self
        def enrichment_attribute(name, enrichment_name = name)
          attribute name do
            @object.enrichments.most_recent&.first&.public_send(enrichment_name)
          end
        end
      end

      type "courses"

      attributes :findable?, :open_for_applications?, :has_vacancies?,
                 :course_code, :name, :study_mode, :qualification, :description,
                 :content_status, :ucas_status, :funding_type,
                 :level, :is_send?, :english, :maths, :science, :gcse_subjects_required,
                 :gcse_grade_required, :age_range_in_years, :accrediting_provider,
                 :accredited_body_code, :level, :degree_grade,
                 :additional_degree_subject_requirements,
                 :degree_subject_requirements, :accept_pending_gcse, :accept_gcse_equivalency,
                 :accept_english_gcse_equivalency, :accept_maths_gcse_equivalency,
                 :accept_science_gcse_equivalency, :additional_gcse_equivalencies,
                 :program_type

      attribute :start_date do
        written_month_year(@object.start_date) if @object.start_date
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

      meta do
        serializer_service = SerializeCourseService.new
        edit_options = @object.edit_course_options

        edit_options[:modern_languages] =
          serializer_service.execute(object: edit_options[:modern_languages])[:serialized][:data]
        edit_options[:subjects] =
          serializer_service.execute(object: edit_options[:subjects])[:serialized][:data]
        edit_options[:modern_languages_subject] =
          serializer_service.execute(object: edit_options[:modern_languages_subject])[:serialized][:data]

        {
          edit_options: edit_options,
        }
      end
    end
  end
end
