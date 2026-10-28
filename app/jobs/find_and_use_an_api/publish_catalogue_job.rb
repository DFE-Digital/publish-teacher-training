# frozen_string_literal: true

module FindAndUseAnAPI
  class PublishCatalogueJob < ApplicationJob
    queue_as :low_priority

    retry_on_failure
    fail_without_retry_on Client::Rejected, PublishCatalogue::Error

    def perform
      return unless Settings.fauapi.enabled

      PublishCatalogue.call
    end
  end
end
