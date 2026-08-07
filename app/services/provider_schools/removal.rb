# frozen_string_literal: true

module ProviderSchools
  class Removal
    def initialize(provider:, uuid:)
      @provider = provider
      @uuid = uuid
    end

    def call
      ActiveRecord::Base.transaction do
        school.with_lock do
          destroy_records_if_removable!
        end
      end
    end

    # Removal is only ever reached by choosing one of the provider's schools,
    # so a uuid that matches no provider school is not a school we can remove.
    def school
      @school ||= provider.schools.find_by!(uuid:)
    end

    # The legacy site dual-written alongside the provider school, destroyed as
    # a by-product of removing it. Absent for schools added after the remodel.
    def site
      @site ||= provider.sites.find_by(uuid:)
    end

    def removable?
      !school.course_schools.joins(:course).merge(Course.kept).exists?
    end

  private

    attr_reader :provider, :uuid

    def destroy_records_if_removable!
      return false unless removable?

      destroy_records!
      true
    end

    def destroy_records!
      school.destroy!
      site&.destroy!
    end
  end
end
