# frozen_string_literal: true

module Publish
  class AccreditedProviderForm < BaseForm
    delegate :provider_name, to: :accredited_provider

    FIELDS = %i[
      description
      accredited_provider_id
    ].freeze

    attr_accessor(*FIELDS)

    validates :description, presence: true

    alias compute_fields new_attributes

    def accredited_provider
      @accredited_provider ||= RecruitmentCycle.current.providers.find(accredited_provider_id)
    end
  end
end
