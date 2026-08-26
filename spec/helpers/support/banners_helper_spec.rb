require "rails_helper"

RSpec.describe Support::BannersHelper, type: :helper do
  describe "#banner_status_tag" do
    context "when banner status is scheduled" do
      it "renders a tag with the Schedule wording and Yellow colour" do
        banner = build_stubbed(:banner)
        allow(banner).to receive(:status).and_return(:scheduled)

        expect(helper.banner_status_tag(banner)).to eq('<strong class="govuk-tag govuk-tag--yellow">Scheduled</strong>')
      end
    end

    context "when banner status is active" do
      it "renders a tag with the Active wording and Green colour" do
        banner = build_stubbed(:banner)
        allow(banner).to receive(:status).and_return(:active)

        expect(helper.banner_status_tag(banner)).to eq('<strong class="govuk-tag govuk-tag--green">Active</strong>')
      end
    end

    context "when banner status is expired" do
      it "renders a tag with the Expired wording and Red colour" do
        banner = build_stubbed(:banner)
        allow(banner).to receive(:status).and_return(:expired)

        expect(helper.banner_status_tag(banner)).to eq('<strong class="govuk-tag govuk-tag--red">Expired</strong>')
      end
    end
  end

  describe "#displayed_on_text" do
    context "when banner displays in all interfaces" do
      it "renders a sentence with all the interface names" do
        banner = build(:banner, display_on_find: true, display_on_publish: true, display_on_support: true)

        expect(helper.displayed_on_text(banner)).to eq("Find, Publish, and Support")
      end
    end

    context "when banner displays in none of the interfaces" do
      it "renders not displayed" do
        banner = build(:banner, display_on_find: false, display_on_publish: false, display_on_support: false)

        expect(helper.displayed_on_text(banner)).to eq("Not displayed")
      end
    end
  end
end
