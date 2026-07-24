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
        if after_schools_remodel_cycle?
          school.with_lock do
            destroy_records_if_removable!
          end
        elsif provider_school.present?
          provider_school.with_lock do
            destroy_records_if_removable!
          end
        else
          destroy_site_if_removable!
        end
      end
    end

    def site
      @site ||= provider.sites.find_by(uuid:) unless after_schools_remodel_cycle?
    end

    def school
      @school ||= identity.school_for(uuid:)
    rescue ActiveRecord::RecordNotFound
      raise if after_schools_remodel_cycle?

      nil
    end

    def provider_school
      @provider_school ||= provider.schools.find_by(uuid:)
    end

    def removable?
      if after_schools_remodel_cycle?
        !school.course_schools.exists?
      else
        site&.has_no_course? && provider_school_course_schools_empty?
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
      provider_school.destroy!
      site&.destroy!
    end

    def provider_school_course_schools_empty?
      provider_school.nil? || !provider_school.course_schools.exists?
    end
  end
end
