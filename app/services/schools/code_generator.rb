# frozen_string_literal: true

module Schools
  # Generates a site_code for a provider's next school relationship.
  # Deterministic (first-available) to keep behaviour predictable for
  # users and tests. Excludes "-" because it is reserved for the provider
  # main site under the partial unique index on provider_school
  # (site_code = '-'). Reads used codes from both the legacy site table
  # and the new provider_school table so codes don't collide on either
  # side during the dual-write period. Race safety is the caller's
  # responsibility (see ProviderSchools::Creator).
  class CodeGenerator
    include ServicePattern

    SINGLE_CHAR_CODES = (("A".."Z").to_a + ("0".."9").to_a).freeze

    def initialize(provider:)
      @provider = provider
    end

    def call
      first_available_single_char || next_sequential_code
    end

  private

    def first_available_single_char
      (SINGLE_CHAR_CODES - used_codes).first
    end

    def next_sequential_code
      multi_char_used = used_codes.reject { |c| c.length <= 1 }
      return "AA" if multi_char_used.empty?

      multi_char_used.max.next
    end

    def used_codes
      @used_codes ||= (
        @provider.sites.pluck(:code) +
        @provider.schools.pluck(:site_code)
      ).compact_blank.uniq
    end
  end
end
