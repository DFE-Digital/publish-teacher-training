# frozen_string_literal: true

require "rails_helper"

describe AccreditedProviderComponent do
  alias_method :component, :page
  let!(:provider) { create(:provider) }

  before do
    render_inline(described_class.new(provider:,
                                      remove_path: "remove_path"))
  end

  it "renders the provider_name title" do
    expect(component).to have_css "h2.govuk-summary-card__title", text: provider.provider_name
  end

  it "renders the provider_name remove link" do
    expect(component).to have_link "Remove", href: "remove_path"
  end
end
