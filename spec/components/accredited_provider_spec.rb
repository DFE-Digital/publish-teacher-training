# frozen_string_literal: true

require 'rails_helper'

describe AccreditedProvider do
  alias_method :component, :page

  before do
    render_inline(described_class.new(provider_name: 'Provider name SCITT',
                                      remove_path: 'remove_path',
                                      about_accredited_provider: 'Enter some random text here',
                                      change_about_accredited_provider_path: 'change_about_accredited_provider_path'))
  end

  it 'renders the about_accredited_provider text' do
    expect(component).to have_css '.govuk-summary-list__value', text: 'Enter some random text here'
  end

  it 'renders the about_accredited_provider key' do
    expect(component).to have_css '.govuk-summary-list__key', text: 'About the accredited provider'
  end

  it 'renders the about_accredited_provider change link' do
    expect(component).to have_link 'Change'
  end

  it 'renders the provider_name title' do
    expect(component).to have_css 'h2.govuk-summary-card__title', text: 'Provider name SCITT'
  end

  it 'renders the provider_name remove link' do
    expect(component).to have_link 'Remove'
  end
end
