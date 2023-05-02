# frozen_string_literal: true

module Providers
  module ProviderList
    class View < ApplicationComponent
      include Support::TimeHelper
      include Publish::ValueHelper

      def initialize(provider:, classes: [], html_attributes: {})
        super(classes:, html_attributes:)
        @provider = provider
      end

      def formatted_provider_type
        Provider.human_attribute_name(@provider.provider_type)
      end

      def formatted_accrediting_provider
        @provider.accredited_provider? ? 'Yes' : 'No'
      end
    end
  end
end
