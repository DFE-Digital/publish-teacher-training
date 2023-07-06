# frozen_string_literal: true

class AddCourseButtonPreview < ViewComponent::Preview
  def with_all_incomplete_sections
    render AddCourseButton.new(provider: FakeProvider.new(study_sites: [], accredited_providers: [], sites: []))
  end

  def with_only_study_site_completed
    render AddCourseButton.new(provider: FakeProvider.new(study_sites: ['study site'], accredited_providers: [], sites: []))
  end

  def with_only_accredited_provider_completed
    render AddCourseButton.new(provider: FakeProvider.new(accredited_providers: ['accredited provider'], study_sites: [], sites: []))
  end

  def with_only_sites_completed
    render AddCourseButton.new(provider: FakeProvider.new(study_sites: [], accredited_providers: [], sites: ['site']))
  end

  def with_study_site_and_accredited_provider_completed
    render AddCourseButton.new(provider: FakeProvider.new(study_sites: ['study site'], accredited_providers: ['accredited provider'], sites: []))
  end

  def with_accredited_provider_and_sites_completed
    render AddCourseButton.new(provider: FakeProvider.new(study_sites: [], accredited_providers: ['accredited provider'], sites: []))
  end

  def with_sites_and_study_sites_completed
    render AddCourseButton.new(provider: FakeProvider.new(study_sites: ['study site'], accredited_providers: [], sites: ['site']))
  end

  def with_all_completed_sections
    render AddCourseButton.new(provider: FakeProvider.new(study_sites: ['study site'], accredited_providers: ['accredited provider'], sites: ['site']))
  end

  class FakeProvider
    include ActiveModel::Model
    attr_accessor(:study_sites, :accredited_providers, :sites)

    def provider_code
      'DFE'
    end

    def recruitment_cycle_year
      2024
    end

    def accredited_provider?
      false
    end
  end
end
