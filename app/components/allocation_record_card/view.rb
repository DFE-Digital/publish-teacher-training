# frozen_string_literal: true

module AllocationRecordCard
  class View < ViewComponent::Base
    with_collection_parameter :allocation
    delegate :provider, :accredited_body, to: :allocation
    delegate :provider_name, to: :provider

    attr_reader :allocation, :heading_level, :recruitment_cycle_year

    def initialize(heading_level = 3, allocation:, allocation_iteration:, recruitment_cycle_year:)
      super
      @allocation = allocation
      @heading_level = heading_level
      @iteration = allocation_iteration
      @recruitment_cycle_year = recruitment_cycle_year
    end

    def provider_code
      tag.p("Provider code: #{provider.provider_code}", class: "govuk-caption-m govuk-!-font-size-16 allocation-record-card__id govuk-!-margin-bottom-0")
    end

    def accredited_body_code
      tag.p("Accrediting Body code: #{accredited_body&.provider_code}", class: "govuk-caption-m govuk-!-font-size-16 allocation-record-card__id govuk-!-margin-bottom-0")
    end

    def accredited_body_name
      tag.p("Accredited by #{accredited_body&.provider_name}", class: "govuk-caption-m govuk-!-font-size-16 allocation-record-card__id govuk-!-margin-bottom-0")
    end

    def number_of_places
      tag.p("Allocated places: #{allocation.confirmed_number_of_places}", class: "govuk-heading-m govuk-!-font-size-16 allocation-record-card__id govuk-!-margin-bottom-0")
    end

    def number_of_uplifts
      tag.p("Allocation Uplifts: #{allocation.allocation_uplift&.uplifts.to_i}", class: "govuk-heading-m govuk-!-font-size-16 allocation-record-card__id govuk-!-margin-bottom-0")
    end
  end
end
