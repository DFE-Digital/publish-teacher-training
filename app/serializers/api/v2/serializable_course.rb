module API
  module V2
    class SerializableCourse < JSONAPI::Serializable::Resource
      class << self
        def enrichment_attribute(name, enrichment_name = name)
          attribute name do
            @object.enrichments.last&.__send__(enrichment_name)
          end
        end
      end

      type 'courses'

      attributes :findable?, :open_for_applications?, :has_vacancies?,
                 :course_code, :name, :study_mode, :qualifications, :description,
                 :content_status, :ucas_status, :funding, :applications_open_from

      attribute :start_date do
        @object.start_date&.iso8601
      end

      attribute :last_published_at do
        @object.last_published_at&.iso8601
      end

      attribute :subjects do
        ucas_subjects = @object.subjects.map(&:subject_name)
        SubjectMapper.get_subject_list(@object.name, ucas_subjects)
      end

      attribute :level do
        ucas_subjects = @object.subjects.map(&:subject_name)
        SubjectMapper.get_subject_level(ucas_subjects)
      end

      attribute :is_send? do
        @object.subjects.any? { |subject| subject.subject_code.casecmp('U3').zero? }
      end

      belongs_to :provider
      belongs_to :accrediting_provider

      has_many :site_statuses

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
      enrichment_attribute :required_qualifications, :qualifications
      enrichment_attribute :salary_details
    end
  end
end
