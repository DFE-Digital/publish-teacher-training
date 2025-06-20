# frozen_string_literal: true

module Providers
  module ProviderList
    class View < ApplicationComponent
      include Support::TimeHelper
      include Publish::ValueHelper

      def initialize(provider:, display_accredited_provider_name: false, display_is_the_organisation_an_accredited_provider: false, display_accredited_provider_number: false, display_contact_details: false, display_change_links: false, classes: [], html_attributes: {})
        super(classes:, html_attributes:)
        @provider = provider
        @display_accredited_provider_name = display_accredited_provider_name
        @display_is_the_organisation_an_accredited_provider = display_is_the_organisation_an_accredited_provider
        @display_accredited_provider_number = display_accredited_provider_number
        @display_contact_details = display_contact_details
        @display_change_links = display_change_links
      end

      def formatted_provider_type
        Provider.human_attribute_name(@provider.provider_type)
      end

      def formatted_accrediting_provider
        @provider.accredited? ? "Yes" : "No"
      end

      def display_accredited_provider_name?
        @display_accredited_provider_name
      end

      def display_is_the_organisation_an_accredited_provider?
        @display_is_the_organisation_an_accredited_provider
      end

      def display_accredited_provider_number?
        @display_accredited_provider_number
      end

      def display_contact_details?
        @display_contact_details
      end

      def display_change_links?
        @display_change_links
      end
    end
  end
end
