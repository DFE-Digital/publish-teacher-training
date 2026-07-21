# frozen_string_literal: true

module ProviderSchools
  class Removal
    class CannotRemoveSchoolError < StandardError; end

    delegate :schools_remodel_cycle?, to: :identity

    def initialize(provider:, uuid:)
      @provider = provider
      @uuid = uuid
      @identity = Identity.new(provider:)
    end

    def call
      raise CannotRemoveSchoolError unless removable?

      ActiveRecord::Base.transaction do
        if schools_remodel_cycle?
          provider_school.destroy!
        else
          provider_school&.destroy!
          site.destroy!
        end
      end
    end

    def site
      @site ||= identity.site_for(uuid:)
    end

    def provider_school
      @provider_school ||= if schools_remodel_cycle?
                             identity.provider_school_for(uuid:)
                           else
                             identity.provider_school_for(site:)
                           end
    rescue ActiveRecord::RecordNotFound
      raise if schools_remodel_cycle?

      nil
    end

    def uuid_for_path
      schools_remodel_cycle? ? provider_school.uuid : identity.uuid_for(site:)
    end

    def removable?
      if schools_remodel_cycle?
        provider_school.course_schools.none?
      else
        site.has_no_course? && provider_school_course_schools_empty?
      end
    end

  private

    attr_reader :provider, :uuid, :identity

    def provider_school_course_schools_empty?
      provider_school.nil? || provider_school.course_schools.none?
    end
  end
end
