# frozen_string_literal: true

require "rails_helper"

module FlashBanner
  describe View do
    alias_method :component, :page

    View::FLASH_TYPES.each do |type|
      context "when flash type is set to: #{type}" do
        let(:referer) { nil }
        let(:message) { "Provider #{type}" }
        let(:flash) { ActionDispatch::Flash::FlashHash.new(type => message) }
        let(:expected_title) do
          { success: "Success", warning: "Important", info: "Important" }[type]
        end

        before do
          render_inline(described_class.new(flash: flash))
        end

        it "renders flash message" do
          expect(component).to have_text(expected_title)
          expect(component).to have_text(message)
        end
      end
    end
  end
end
