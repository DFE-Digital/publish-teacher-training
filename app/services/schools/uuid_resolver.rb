# frozen_string_literal: true

module Schools
  # Resolves school UUIDs to the provider's own school records, preserving the
  # order they were submitted in and reporting back any UUID that does not
  # belong to the provider.
  #
  # Every layer of the add-course flow needs the same lookup but reacts to an
  # unrecognised UUID differently - the wizard step raises a form error the
  # provider can fix, the draft degrades so the review row still renders, and
  # course creation errors the course. Only the lookup is shared here; the
  # reaction stays with the caller.
  #
  # TODO School data remodel - the scope below becomes provider.schools once the
  # add-course flow reads the new model. Schools are keyed by UUID precisely so
  # that swap is a one-line change here rather than one per caller.
  class UuidResolver
    include ServicePattern

    Result = Struct.new(:schools, :unrecognised_uuids, keyword_init: true) do
      def unrecognised?
        unrecognised_uuids.any?
      end
    end

    def initialize(provider:, uuids:, log_tag:)
      @provider = provider
      @uuids = Array(uuids).compact_blank.map(&:to_s)
      @log_tag = log_tag
    end

    def call
      return Result.new(schools: [], unrecognised_uuids: []) if uuids.empty?

      log_unrecognised if unrecognised_uuids.any?

      Result.new(schools:, unrecognised_uuids:)
    end

  private

    attr_reader :provider, :uuids, :log_tag

    def schools
      @schools ||= uuids.filter_map { |uuid| schools_by_uuid[uuid] }
    end

    def unrecognised_uuids
      @unrecognised_uuids ||= uuids - schools_by_uuid.keys
    end

    def schools_by_uuid
      @schools_by_uuid ||= provider.sites.where(uuid: uuids).index_by { |site| site.uuid.to_s }
    end

    def log_unrecognised
      Rails.logger.warn(
        "[#{log_tag}] unrecognised school UUIDs for provider=#{provider.id}: " \
        "#{unrecognised_uuids.join(', ')}",
      )
    end
  end
end
