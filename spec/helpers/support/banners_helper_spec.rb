require "rails_helper"

RSpec.describe Support::BannersHelper, type: :helper do
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
