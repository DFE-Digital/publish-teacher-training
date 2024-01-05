# frozen_string_literal: true

require 'rails_helper'

describe AddCourseButton do
  include Rails.application.routes.url_helpers

  let(:recruitment_cycle) { build(:recruitment_cycle, :next) }
  let(:provider) { build(:provider, recruitment_cycle:) }

  before do
    render_inline(described_class.new(provider:))
  end

  context 'when the provider has not filled out any required sections' do
    it 'renders an accredited provider link' do
      expect(rendered_content).to have_link(
        'add an accredited provider',
        href: publish_provider_recruitment_cycle_accredited_providers_path(
          provider.provider_code,
          provider.recruitment_cycle.year
        )
      )
    end

    it 'renders a schools link' do
      expect(rendered_content).to have_link(
        'add a school',
        href: publish_provider_recruitment_cycle_schools_path(
          provider.provider_code,
          provider.recruitment_cycle.year
        )
      )
    end
  end

  context 'when the provider has only added a study site' do
    let(:provider) { build(:provider, study_sites: [build(:site, :study_site)], recruitment_cycle:) }

    it 'renders a study sites link' do
      expect(rendered_content).to have_no_link(
        'add a study site',
        href: publish_provider_recruitment_cycle_study_sites_path(
          provider.provider_code,
          provider.recruitment_cycle_year
        )
      )
    end

    it 'renders an accredited provider link' do
      expect(rendered_content).to have_link(
        'add an accredited provider',
        href: publish_provider_recruitment_cycle_accredited_providers_path(
          provider.provider_code,
          provider.recruitment_cycle.year
        )
      )
    end

    it 'renders a schools link' do
      expect(rendered_content).to have_link(
        'add a school',
        href: publish_provider_recruitment_cycle_schools_path(
          provider.provider_code,
          provider.recruitment_cycle.year
        )
      )
    end
  end

  context 'when the provider is an accredited provider' do
    let(:provider) { build(:provider, :accredited_provider, recruitment_cycle:) }

    it 'renders an accredited provider link' do
      expect(rendered_content).to have_no_link(
        'add an accredited provider',
        href: publish_provider_recruitment_cycle_accredited_providers_path(
          provider.provider_code,
          provider.recruitment_cycle.year
        )
      )
    end

    it 'renders a schools link' do
      expect(rendered_content).to have_link(
        'add a school',
        href: publish_provider_recruitment_cycle_schools_path(
          provider.provider_code,
          provider.recruitment_cycle.year
        )
      )
    end
  end

  context 'when the provider has only added a site' do
    let(:provider) { build(:provider, sites: [create(:site)], recruitment_cycle:) }

    it 'renders an accredited provider link' do
      expect(rendered_content).to have_link(
        'add an accredited provider',
        href: publish_provider_recruitment_cycle_accredited_providers_path(
          provider.provider_code,
          provider.recruitment_cycle.year
        )
      )
    end

    it 'renders a schools link' do
      expect(rendered_content).to have_no_link(
        'add a school',
        href: publish_provider_recruitment_cycle_schools_path(
          provider.provider_code,
          provider.recruitment_cycle.year
        )
      )
    end
  end

  context 'when the provider has added a site and a study site' do
    let(:provider) { build(:provider, study_sites: [build(:site, :study_site)], sites: [build(:site)], recruitment_cycle:) }

    it 'renders a study sites link' do
      expect(rendered_content).to have_no_link(
        'add a study site',
        href: publish_provider_recruitment_cycle_study_sites_path(
          provider.provider_code,
          provider.recruitment_cycle_year
        )
      )
    end

    it 'renders an accredited provider link' do
      expect(rendered_content).to have_link(
        'add an accredited provider',
        href: publish_provider_recruitment_cycle_accredited_providers_path(
          provider.provider_code,
          provider.recruitment_cycle.year
        )
      )
    end

    it 'renders a schools link' do
      expect(rendered_content).to have_no_link(
        'add a school',
        href: publish_provider_recruitment_cycle_schools_path(
          provider.provider_code,
          provider.recruitment_cycle.year
        )
      )
    end
  end

  context 'when the provider has added all required organisation details' do
    let(:provider) { build(:provider, :accredited_provider, study_sites: [build(:site, :study_site)], sites: [build(:site)], recruitment_cycle:) }

    it 'renders a study sites link' do
      expect(rendered_content).to have_no_link(
        'add a study site',
        href: publish_provider_recruitment_cycle_study_sites_path(
          provider.provider_code,
          provider.recruitment_cycle_year
        )
      )
    end

    it 'renders an accredited provider link' do
      expect(rendered_content).to have_no_link(
        'add an accredited provider',
        href: publish_provider_recruitment_cycle_accredited_providers_path(
          provider.provider_code,
          provider.recruitment_cycle.year
        )
      )
    end

    it 'renders a schools link' do
      expect(rendered_content).to have_no_link(
        'add a school',
        href: publish_provider_recruitment_cycle_schools_path(
          provider.provider_code,
          provider.recruitment_cycle.year
        )
      )
    end
  end
end
