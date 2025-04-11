# frozen_string_literal: true

require "rails_helper"

describe FlashBanner do
  alias_method :component, :page

  FlashBanner::FLASH_TYPES.each do |type|
    context "when flash type is set to: #{type}" do
      let(:referer) { nil }
      let(:message) { "Provider #{type}" }
      let(:flash) { ActionDispatch::Flash::FlashHash.new(type => message) }
      let(:expected_title) do
        { success: "Success", warning: "Important", info: "Important" }[type.to_sym]
      end

      before do
        render_inline(described_class.new(flash:))
      end

      it "renders flash message" do
        expect(component).to have_text(expected_title)
        expect(component).to have_text(message)
      end
    end
  end
end
