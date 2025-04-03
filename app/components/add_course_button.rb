# frozen_string_literal: true

class AddCourseButton < ViewComponent::Base
  include RecruitmentCycleHelper
  attr_reader :provider

  Section = Struct.new(:text, :path, keyword_init: true)

  def initialize(provider:)
    super
    @provider = provider
  end

  def required_organisation_details_present?
    incomplete_sections.empty?
  end

  def incomplete_sections
    @incomplete_sections ||= [school, accredited_provider].compact
  end

private

  def accredited_provider
    return if accredited_partner_present?

    Section.new(text: t("components.add_course_button.add_accredited_provider"), path: publish_provider_recruitment_cycle_accredited_partnerships_path(provider.provider_code, provider.recruitment_cycle_year))
  end

  def school
    return if school_present?

    Section.new(text: t("components.add_course_button.add_school"), path: publish_provider_recruitment_cycle_schools_path(provider.provider_code, provider.recruitment_cycle_year))
  end

  def accredited_partner_present?
    return true if provider.accredited?

    provider.accredited_partners.any?
  end

  def school_present?
    provider.sites.any?
  end
end
