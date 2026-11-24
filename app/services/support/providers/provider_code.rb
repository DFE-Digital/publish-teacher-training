# frozen_string_literal: true

module Support
  module Providers
    class ProviderCode
      include ServicePattern

      CHARACTERS = (("A".."Z").to_a + ("0".."9").to_a).freeze
      ATTEMPTS = 30

      def initialize(recruitment_cycle:)
        @recruitment_cycle = recruitment_cycle
      end

      def call
        ATTEMPTS.times do
          code = Array.new(3) { CHARACTERS.sample }.join
          next unless Support::ProviderForm::PROVIDER_CODE_FORMAT.match?(code)
          next if code_taken_in_cycle?(code)

          return code
        end

        nil
      end

    private

      attr_reader :recruitment_cycle

      def code_taken_in_cycle?(code)
        Provider.with_discarded.exists?(recruitment_cycle:, provider_code: code)
      end
    end
  end
end
