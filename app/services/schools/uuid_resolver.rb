# frozen_string_literal: true

module Schools
  class UuidResolver
    def initialize(provider:, uuids:, log_tag:)
      @provider = provider
      @uuids = Array(uuids).compact_blank.map(&:to_s)
      @log_tag = log_tag
    end

    def schools
      @schools ||= ordered(schools_by_uuid)
    end

    def sites
      @sites ||= ordered(sites_by_uuid)
    end

    def unrecognised_uuids
      log_unrecognised
      unrecognised
    end

    def unrecognised?
      unrecognised_uuids.any?
    end

  private

    attr_reader :provider, :uuids, :log_tag

    def ordered(records_by_uuid)
      log_unrecognised
      uuids.filter_map { |uuid| records_by_uuid[uuid] }
    end

    def unrecognised
      @unrecognised ||= uuids - schools_by_uuid.keys
    end

    def sites_by_uuid
      @sites_by_uuid ||= provider.sites.where(uuid: uuids).index_by { |site| site.uuid.to_s }
    end

    def schools_by_uuid
      @schools_by_uuid ||= provider.schools.includes(:gias_school).where(uuid: uuids).index_by { |school| school.uuid.to_s }
    end

    def log_unrecognised
      return if @logged || unrecognised.empty?

      @logged = true

      Rails.logger.warn(
        "[#{log_tag}] unrecognised school UUIDs for provider=#{provider.id}: " \
        "#{unrecognised.join(', ')}",
      )
    end
  end
end
