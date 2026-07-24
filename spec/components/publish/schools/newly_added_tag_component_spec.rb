# frozen_string_literal: true

require "rails_helper"

RSpec.describe Publish::Schools::NewlyAddedTagComponent, type: :component do
  let(:recruitment_cycle) { find_or_create(:recruitment_cycle, year: 2026) }
  let(:provider) { create(:provider, recruitment_cycle:) }

  it "does not render for provider schools without a matching legacy site" do
    provider_school = create(:provider_school, provider:)

    render_inline(described_class.new(school: provider_school))

    expect(page).not_to have_css(".newly-added-tag")
  end

  it "renders for provider schools backed by a register import legacy site during the 2026 rollover period" do
    gias_school = create(:gias_school)
    site = create(:site, provider:, added_via: :register_import, urn: gias_school.urn)
    provider_school = create(:provider_school, provider:, gias_school:, site_code: site.code, uuid: site.uuid)

    render_inline(described_class.new(school: provider_school))

    expect(page).to have_css(".newly-added-tag", text: "Newly added")
  end

  it "renders for register import legacy sites during the 2026 rollover period" do
    site = create(:site, provider:, added_via: :register_import)

    render_inline(described_class.new(school: site))

    expect(page).to have_css(".newly-added-tag", text: "Newly added")
  end
end
