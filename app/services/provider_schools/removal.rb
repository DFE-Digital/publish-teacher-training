# frozen_string_literal: true

module ProviderSchools
  class Removal
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
            destroy_records_if_removable!
          end
        else
          destroy_site_if_removable!
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

    def removable?
      if after_schools_remodel_cycle?
        !provider_school.course_schools.exists?
      else
        site.has_no_course? && provider_school_course_schools_empty?
      end
    end

  private

    attr_reader :provider, :uuid, :identity

    def destroy_records_if_removable!
      return false unless removable?

      destroy_records!
      true
    end

    def destroy_site_if_removable!
      return false unless removable?

      site.destroy!
      true
    end

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
