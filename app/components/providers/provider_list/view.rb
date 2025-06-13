# frozen_string_literal: true

module Providers
  module ProviderList
    class View < ApplicationComponent
      include Support::TimeHelper
      include Publish::ValueHelper

      def initialize(provider:, display_change_links: false, classes: [], html_attributes: {})
        super(classes:, html_attributes:)
        @provider = provider
        @display_change_links = display_change_links
      end

      def formatted_provider_type
        Provider.human_attribute_name(@provider.provider_type)
      end

      def formatted_accrediting_provider
        @provider.accredited? ? "Yes" : "No"
      end

      def display_change_links?
        @display_change_links
      end
    end
  end
end
