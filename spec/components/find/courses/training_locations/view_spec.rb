# frozen_string_literal: true

require 'rails_helper'

describe Find::Courses::TrainingLocations::View, type: :component do
  subject { render_inline(described_class.new(course:, preview:)) }

  let(:preview) { false }
  let(:component) { described_class.new(course:, preview:) }

  describe '#render' do
    let(:study_site) { course.study_sites.first.decorate }

    context 'for fee-paying courses' do
      let(:course) { create(:course, :with_full_time_sites, funding: 'fee', study_sites: [build(:site, :study_site)]) }

      it "renders the 'Placement schools' heading" do
        expect(subject).to have_css('.govuk-summary-list__key', text: 'Placement schools')
      end

      it 'renders the link to school placements' do
        expect(subject).to have_link('View list of school placements')
      end

      it 'renders the hint about placements not being guaranteed' do
        expect(subject).to have_css('.govuk-hint', text: 'Schools can change and are not guaranteed')
      end
    end

    context 'for salaried courses' do
      let(:course) { create(:course, :with_full_time_sites, funding: 'salary', study_sites: [build(:site, :study_site)]) }

      it "renders the 'Employing schools' heading" do
        expect(subject).to have_css('.govuk-summary-list__key', text: 'Employing schools')
      end

      it 'renders the link to employing schools' do
        expect(subject).to have_link('View list of school placements')
      end

      it 'renders the hint about placements not being guaranteed' do
        expect(subject).to have_css('.govuk-hint', text: 'Schools can change and are not guaranteed')
      end

      it "renders 'Where you will study' for study sites" do
        expect(subject).to have_css('.govuk-summary-list__key', text: 'Where you will study')
      end

      it 'renders the study site names and addresses' do
        expect(subject).to have_css('.govuk-hint strong', text: study_site.location_name)
        expect(subject).to have_css('.govuk-hint', text: study_site.full_address)
      end
    end
  end

  describe '#placements_url' do
    let(:provider) { create(:provider, recruitment_cycle: find_or_create(:recruitment_cycle, year:), selectable_school:) }
    let(:course) { create(:course, provider:) }
    let(:year) { 2025 }
    let(:selectable_school) { false }

    context 'when preview = true, before 2025 find opens and provider != selectable_school' do
      let(:preview) { true }
      let(:year) { 2025 }
      let(:selectable_school) { false }

      it 'renders link to the publish path for 2025 provider' do
        expect(subject).to have_no_link(
          'View list of school placements',
          href: url_helpers.placements_publish_provider_recruitment_cycle_course_path(
            course.provider_code,
            course.recruitment_cycle_year,
            course.course_code
          )
        )
      end
    end

    context 'when preview is false after find opens in 2025 and provider has selectable_school enabled' do
      let(:year) { 2025 }
      let(:selectable_school) { true }

      it 'renders a link to the find path' do
        expect(subject).to have_link('View list of school placements',
                                     href: url_helpers.find_placements_path(course.provider_code, course.course_code))
      end
    end
  end

  describe '#potential_placements_text' do
    context 'for fee-paying courses' do
      let(:course) { create(:course, :with_full_time_sites, funding: 'fee', study_sites: [build(:site, :study_site)]) }

      it 'returns the correct text for one potential placement location' do
        expect(component.potential_placements_text).to eq('1 potential placement school')
      end
    end

    context 'for salaried courses' do
      let(:course) { create(:course, :with_full_time_sites, funding: 'salary', study_sites: [build(:site, :study_site)]) }

      it 'returns the correct text for one potential employing school' do
        expect(component.potential_placements_text).to eq('1 potential employing school')
      end
    end

    context 'with multiple placements' do
      let(:course) { create(:course, funding: 'fee', sites: [create(:site), create(:site), create(:site)]) }

      it 'returns the correct text for multiple placements' do
        expect(component.potential_placements_text).to eq('3 potential placement schools')
      end
    end
  end

  describe '#potential_study_sites_text' do
    let(:course) { create(:course, :with_full_time_sites) }

    context 'when there is one study site' do
      let(:course) { create(:course, :with_full_time_sites, study_sites: [build(:site, :study_site)]) }

      it 'returns the correct text for one study site' do
        expect(component.potential_study_sites_text).to eq('1 study site')
      end
    end

    context 'when there are multiple study sites' do
      let(:course) { create(:course, :with_full_time_sites, study_sites: [build(:site, :study_site), build(:site, :study_site)]) }

      it 'returns the correct text for multiple study sites' do
        expect(component.potential_study_sites_text).to eq('2 potential study sites')
      end
    end

    context 'when there are no study sites' do
      let(:course) { create(:course, :with_full_time_sites, study_sites: []) }

      it 'returns the correct text for no study sites' do
        expect(component.potential_study_sites_text).to eq('Not listed yet')
      end
    end
  end

  def url_helpers
    Rails.application.routes.url_helpers
  end
end
