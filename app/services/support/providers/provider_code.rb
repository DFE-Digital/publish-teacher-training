# frozen_string_literal: true

module Support
  module Providers
    class ProviderCode
      include ServicePattern

      CHARACTERS = (("A".."Z").to_a + ("0".."9").to_a).freeze

      def initialize(recruitment_cycle:)
        @recruitment_cycle = recruitment_cycle
      end

      def call
        taken_codes = Provider.with_discarded.where(recruitment_cycle:).pluck(:provider_code)

        (valid_codes - taken_codes).sample
      end

    private

      attr_reader :recruitment_cycle

      def valid_codes
        CHARACTERS.repeated_permutation(3).filter_map do |characters|
          code = characters.join
          code if Support::ProviderForm::PROVIDER_CODE_FORMAT.match?(code)
        end
      end
    end
  end
end
