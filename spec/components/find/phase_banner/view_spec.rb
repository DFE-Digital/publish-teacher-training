# frozen_string_literal: true

require 'rails_helper'

module Find
  module PhaseBanner
    RSpec.describe View, type: :component do
      it 'renders the feedback link' do
        result = render_inline(described_class.new)

        mailto_link = result.css('a.govuk-link.govuk-link--no-visited-state')[0]
        expect(mailto_link['href']).to include('subject=Feedback%20about%20Find%20teacher%20training%20courses')
        expect(page.text).to include('Give feedback or report a problem: becomingateacher@digital.education.gov.uk')
      end

      {
        'development' => 'grey',
        'qa' => 'orange',
        'review' => 'purple',
        'sandbox' => 'purple',
        'staging' => 'red',
        'unknown-environment' => 'yellow'
      }.each do |environment, colour|
        it "renders a #{colour} phase banner for the #{environment} environment" do
          allow(Settings.environment).to receive(:name).and_return(environment)
          render_inline(described_class.new)

          expect(page).to have_css(".govuk-phase-banner .govuk-tag--#{colour}")
        end
      end

      context "when no value is passed in to 'no_border'" do
        it 'renders a border' do
          render_inline(described_class.new)
          expect(page).to have_no_css('.app-phase-banner--no-border')
        end
      end

      context "when true is passed in to 'no_border'" do
        it 'does not render a border' do
          render_inline(described_class.new(no_border: true))
          expect(page).to have_css('.app-phase-banner--no-border')
        end
      end
    end
  end
end
