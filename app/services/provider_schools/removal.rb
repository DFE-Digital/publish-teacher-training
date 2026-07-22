# frozen_string_literal: true

module ProviderSchools
  class Removal
    class CannotRemoveSchoolError < StandardError; end

    delegate :after_schools_remodel_cycle?, to: :identity

    def initialize(provider:, uuid:)
      @provider = provider
      @uuid = uuid
      @identity = Identity.new(provider:)
    end

    def call
      ActiveRecord::Base.transaction do
        if provider_school.present?
          provider_school.with_lock do
            raise CannotRemoveSchoolError unless removable?

            destroy_records!
          end
        else
          raise CannotRemoveSchoolError unless removable?

          site.destroy!
        end
      end
    end

    def site
      @site ||= school if school.is_a?(Site)
    end

    def school
      @school ||= identity.school_for(uuid:)
    end

    def provider_school
      @provider_school ||= if after_schools_remodel_cycle?
                             school
                           else
                             identity.provider_school_for(site:)
                           end
    rescue ActiveRecord::RecordNotFound
      raise if after_schools_remodel_cycle?

      nil
    end

    def uuid_for_path
      school.uuid
    end

    def removable?
      if after_schools_remodel_cycle?
        !provider_school.course_schools.exists?
      else
        site.has_no_course? && provider_school_course_schools_empty?
      end
    end

  private

    attr_reader :provider, :uuid, :identity

    def destroy_records!
      if after_schools_remodel_cycle?
        provider_school.destroy!
      else
        provider_school.destroy!
        site.destroy!
      end
    end

    def provider_school_course_schools_empty?
      provider_school.nil? || !provider_school.course_schools.exists?
    end
  end
end
