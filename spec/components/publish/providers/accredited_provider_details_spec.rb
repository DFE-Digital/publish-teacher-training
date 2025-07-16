require "rails_helper"

RSpec.describe Publish::Providers::AccreditedProviderDetails, type: :component do
  let(:provider) { build_stubbed(:provider, provider_code: "ABC", ukprn: "12345678", provider_type: "university", accredited: true) }

  it "renders the provider details summary list" do
    render_inline(described_class.new(provider: provider))

    expect(page).to have_text("Provider Code")
    expect(page).to have_text("ABC")
    expect(page).to have_text("UK provider reference number (UKPRN)")
    expect(page).to have_text("12345678")
    expect(page).to have_text("Provider type")
    expect(page).to have_text("University")
  end
end
