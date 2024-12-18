# frozen_string_literal: true

class AddCourseButton < ViewComponent::Base
  include RecruitmentCycleHelper
  attr_reader :provider

  Section = Struct.new(:name, :path, keyword_init: true)

  def initialize(provider:)
    @provider = provider
    super
  end

  private

  def incomplete_sections
    incomplete_sections_hash.keys.select { |section| send(section) }.map do |section|
      Section.new(name: "add #{incomplete_section_article(section)} #{incomplete_section_label_suffix(section)}", path: incomplete_sections_hash[section])
    end
  end

  def incomplete_sections_hash
    {
      site_not_present?: publish_provider_recruitment_cycle_schools_path(provider.provider_code, provider.recruitment_cycle_year),
      accredited_provider_not_present?: publish_provider_recruitment_cycle_accredited_providers_path(provider.provider_code, provider.recruitment_cycle_year)
    }
  end

  def incomplete_section_label_suffix(section)
    labels = {
      accredited_provider_not_present?: 'accredited provider',
      site_not_present?: 'school'
    }

    labels[section]
  end

  def required_organisation_details_present?
    accredited_provider_present? && site_present?
  end

  def accredited_provider_present?
    return true if accredited_provider?

    provider.accredited_providers.any?
  end

  def site_present?
    provider.sites.any?
  end

  def accredited_provider_not_present?
    return false if provider.accredited_provider?

    !accredited_provider_present?
  end

  def site_not_present?
    !site_present?
  end

  def accredited_provider?
    provider.accredited_provider?
  end

  def incomplete_section_article(section)
    incomplete_section_label_suffix(section) == 'accredited provider' ? 'an' : 'a'
  end
end
