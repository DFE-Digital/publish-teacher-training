# frozen_string_literal: true

require "rails_helper"

module FlashBanner
  describe View do
    alias_method :component, :page

    let(:referer) { nil }
    let(:message) { "Provider #{type}" }
    let(:type) { View::FLASH_TYPES.sample }
    let(:flash) { ActionDispatch::Flash::FlashHash.new(type => message) }
    let(:expected_title) { type == :success ? "Success" : "Important" }

    before do
      render_inline(described_class.new(flash: flash))
    end

    it "renders flash message" do
      expect(component).to have_text(expected_title)
      expect(component).to have_text(message)
    end
  end
end
