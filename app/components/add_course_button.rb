# frozen_string_literal: true

class AddCourseButton < ViewComponent::Base
  include RecruitmentCycleHelper
  attr_reader :provider

  Section = Struct.new(:text, :path, keyword_init: true)

  def initialize(provider:)
    super()
    @provider = provider
  end

  def required_organisation_details_present?
    incomplete_sections.empty?
  end

  def incomplete_sections
    @incomplete_sections ||= [school, accredited_provider].compact
  end

  def add_course_path
    if wizard_add_course_flow?
      new_publish_provider_recruitment_cycle_course_wizard_path(
        provider_code: provider.provider_code,
        recruitment_cycle_year: provider.recruitment_cycle_year,
        state_key: wizard_state_key,
      )
    else
      new_publish_provider_recruitment_cycle_course_path(
        provider_code: provider.provider_code,
        recruitment_cycle_year: provider.recruitment_cycle_year,
      )
    end
  end

private

  def wizard_add_course_flow?
    FeatureFlag.active?(:wizard_add_course_flow)
  end

  def wizard_state_key
    @wizard_state_key ||= SecureRandom.uuid
  end

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
