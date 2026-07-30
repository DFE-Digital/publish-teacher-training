# frozen_string_literal: true

require "rails_helper"

RSpec.describe Publish::Schools::NewlyAddedTagComponent, type: :component do
  let(:recruitment_cycle) { RecruitmentCycle.find_by(year: "2026") || create(:recruitment_cycle, year: "2026") }
  let(:provider) { create(:provider, recruitment_cycle:) }

  # rollover_period_2026? is a real time window, so move the clock rather than
  # stubbing it — the component reads the cycle off the school, not from here.
  around do |example|
    offset = rollover ? 1.day : 60.days
    travel_to(Find::CycleTimetable.find_opens(2026) + offset) { example.run }
  end

  # The picker renders Provider::School rows, but "added via the register
  # import" is only recorded on the legacy site, so the tag has to reach
  # through the uuid pairing.
  context "with a provider school paired to a register-imported site" do
    let(:rollover) { true }

    it "renders the tag" do
      provider_school = paired_provider_school(added_via: :register_import)

      render_inline(described_class.new(school: provider_school))

      expect(page).to have_css(".newly-added-tag")
    end
  end

  context "with a provider school paired to a site added through publish" do
    let(:rollover) { true }

    it "does not render the tag" do
      provider_school = paired_provider_school(added_via: :publish_interface)

      render_inline(described_class.new(school: provider_school))

      expect(page).not_to have_css(".newly-added-tag")
    end
  end

  context "with a provider school that has no paired site" do
    let(:rollover) { true }

    it "does not render the tag" do
      provider_school = create(:provider_school, provider:)

      render_inline(described_class.new(school: provider_school))

      expect(page).not_to have_css(".newly-added-tag")
    end
  end

  context "outside the 2026 rollover period" do
    let(:rollover) { false }

    it "does not render the tag" do
      provider_school = paired_provider_school(added_via: :register_import)

      render_inline(described_class.new(school: provider_school))

      expect(page).not_to have_css(".newly-added-tag")
    end
  end

  context "with a legacy site" do
    let(:rollover) { true }

    it "still renders the tag" do
      site = create(:site, provider:, added_via: :register_import)

      render_inline(described_class.new(school: site))

      expect(page).to have_css(".newly-added-tag")
    end
  end

  def paired_provider_school(added_via:)
    uuid = SecureRandom.uuid
    gias_school = create(:gias_school)
    create(:site, provider:, uuid:, code: "A", urn: gias_school.urn, added_via:)
    create(:provider_school, provider:, gias_school:, site_code: "A", uuid:)
  end
end
