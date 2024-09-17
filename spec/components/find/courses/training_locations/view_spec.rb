# frozen_string_literal: true

require 'rails_helper'

describe Find::Courses::TrainingLocations::View, type: :component do
  include Rails.application.routes.url_helpers

  subject { render_inline(described_class.new(course:, preview:)) }

  let(:course) { create(:course, :with_full_time_sites, study_sites: [build(:site, :study_site)]) }
  let(:study_site) { course.study_sites.first.decorate }
  let(:preview) { false }
  let(:component) { described_class.new(course:, preview:) }

  describe '#render' do
    context 'when displaying school placements' do
      it "renders the 'school placements' key" do
        expect(subject).to have_css('.govuk-summary-list__key', text: 'Placement schools')
      end

      it 'renders the link to school placements' do
        expect(subject).to have_link('View list of school placements')
      end

      it 'renders the hint about school placements not being guaranteed' do
        expect(subject).to have_css('.govuk-hint', text: 'Locations can change and are not guaranteed')
      end
    end

    context 'when displaying study site (singular)' do
      it "renders the 'Where you will study' key" do
        expect(subject).to have_css('.govuk-summary-list__key', text: 'Where you will study')
      end

      it 'renders the potential placement location text' do
        expect(subject).to have_css('.govuk-body', text: '1 potential placement location')
      end

      it 'renders the study site names and addresses' do
        expect(subject).to have_css('.govuk-hint strong', text: study_site.location_name)
        expect(subject).to have_css('.govuk-hint', text: study_site.full_address)
      end
    end
  end

  describe '#placements_url' do
    context 'when preview is true' do
      let(:preview) { true }

      it 'renders a link to the placements publish path' do
        expect(subject).to have_link(
          'View list of school placements',
          href: placements_publish_provider_recruitment_cycle_course_path(
            course.provider_code,
            course.recruitment_cycle_year,
            course.course_code
          )
        )
      end
    end

    context 'when preview is false' do
      let(:preview) { false }

      it 'returns the find placements path' do
        expect(subject).to have_link('View list of school placements',
                                     href: find_placements_path(course.provider_code, course.course_code))
      end
    end
  end

  describe 'potential_placement_schools_text' do
    context 'when there is one school' do
      it 'returns 1 potential placement location' do
        expect(component.potential_placements_text).to eq('1 potential placement location')
      end
    end

    context 'when there are three schools' do
      let(:course) { create(:course, sites: [create(:site), create(:site), create(:site)]) }

      it 'returns three potential placement locations' do
        expect(component.potential_placements_text).to eq('3 potential placement locations')
      end
    end
  end

  describe 'potential_study_sites_text' do
    context 'when there is one study site' do
      it 'returns 1 potential placement location' do
        expect(component.potential_study_sites_text).to eq('1 potential study site')
      end
    end

    context 'when there are two study sites' do
      let(:course) { create(:course, :with_full_time_sites, study_sites: [build(:site, :study_site), build(:site, :study_site)]) }

      it 'returns q potential placement locations' do
        expect(component.potential_study_sites_text).to eq('2 potential study sites')
      end
    end

    context 'when there are no study sites' do
      let(:course) { create(:course, :with_full_time_sites, study_sites: []) }

      it 'returns q potential placement locations' do
        expect(component.potential_study_sites_text).to eq('No study sites')
      end
    end
  end
end
