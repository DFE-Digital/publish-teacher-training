# frozen_string_literal: true

require "rails_helper"

describe FlashBanner do
  alias_method :component, :page

  describe "standard flash types" do
    FlashBanner::FLASH_TYPES.each do |type|
      context "when flash type is set to: #{type}" do
        let(:message) { "Provider #{type}" }
        let(:flash) { ActionDispatch::Flash::FlashHash.new(type => message) }
        let(:expected_title) do
          { success: "Success", warning: "Important", info: "Important" }[type.to_sym]
        end

        before do
          render_inline(described_class.new(flash:))
        end

        it "renders flash message with correct title" do
          expect(component).to have_text(expected_title)
          expect(component).to have_text(message)
        end

        it "renders using govuk_notification_banner" do
          expect(component).to have_css(".govuk-notification-banner")
        end

        it "marks success type with success class" do
          if type == "success"
            expect(component).to have_css(".govuk-notification-banner--success")
          else
            expect(component).not_to have_css(".govuk-notification-banner--success")
          end
        end
      end
    end
  end

  describe "error flash type" do
    let(:flash) do
      ActionDispatch::Flash::FlashHash.new(
        "error" => { "id" => "field-name", "message" => "This field is required" },
      )
    end

    before do
      render_inline(described_class.new(flash:))
    end

    it "renders error summary" do
      expect(component).to have_css(".govuk-error-summary")
      expect(component).to have_text("There is a problem")
    end

    it "renders error message with link" do
      expect(component).to have_link("This field is required", href: "#field-name")
    end

    it "has correct ARIA attributes" do
      expect(component).to have_css('[role="alert"]')
      expect(component).to have_css('[aria-labelledby="error-summary-title"]')
    end

    it "has data attributes for analytics" do
      expect(component).to have_css('[data-module="govuk-error-summary"]')
    end
  end

  describe "success_with_body flash type" do
    let(:flash) do
      ActionDispatch::Flash::FlashHash.new(
        "success_with_body" => {
          "title" => "Application submitted",
          "body" => "Your reference number is <strong>ABC123</strong>",
        },
      )
    end

    before do
      render_inline(described_class.new(flash:))
    end

    it "renders notification banner with title and body" do
      expect(component).to have_css(".govuk-notification-banner--success")
      expect(component).to have_text("Application submitted")
      expect(component).to have_text("Your reference number is ABC123")
    end

    it "renders HTML in body safely" do
      expect(component).to have_css("strong", text: "ABC123")
    end

    it "has correct ARIA role" do
      expect(component).to have_css('.govuk-notification-banner[role="alert"]')
    end
  end

  describe "multiple flash messages" do
    let(:flash) do
      ActionDispatch::Flash::FlashHash.new(
        "success" => "Changes saved",
        "warning" => "Review required",
        "info" => "New feature available",
      )
    end

    before do
      render_inline(described_class.new(flash:))
    end

    it "renders all flash messages" do
      expect(component).to have_text("Changes saved")
      expect(component).to have_text("Review required")
      expect(component).to have_text("New feature available")
    end

    it "renders multiple notification banners" do
      expect(component).to have_css(".govuk-notification-banner", count: 3)
    end
  end

  describe "unknown flash types" do
    let(:flash) do
      ActionDispatch::Flash::FlashHash.new(
        "custom_type" => "This should not render",
        "success" => "This should render",
      )
    end

    before do
      render_inline(described_class.new(flash:))
    end

    it "only renders known flash types" do
      expect(component).to have_text("This should render")
      expect(component).not_to have_text("This should not render")
    end

    it "renders only one notification banner" do
      expect(component).to have_css(".govuk-notification-banner", count: 1)
    end
  end

  describe "#render?" do
    context "when flash has messages" do
      let(:flash) { ActionDispatch::Flash::FlashHash.new("success" => "Message") }
      let(:flash_banner) { described_class.new(flash:) }

      it "returns true" do
        expect(flash_banner.render?).to be true
      end
    end

    context "when flash is empty" do
      let(:flash) { ActionDispatch::Flash::FlashHash.new }
      let(:flash_banner) { described_class.new(flash:) }

      it "returns false" do
        expect(flash_banner.render?).to be false
      end

      it "does not render component" do
        render_inline(flash_banner)
        expect(component.text).to be_empty
      end
    end
  end

  describe "#title" do
    let(:flash) { ActionDispatch::Flash::FlashHash.new }
    let(:flash_banner) { described_class.new(flash:) }

    it "returns 'Success' for success type" do
      expect(flash_banner.title("success")).to eq("Success")
    end

    it "returns 'Important' for warning type" do
      expect(flash_banner.title("warning")).to eq("Important")
    end

    it "returns 'Important' for info type" do
      expect(flash_banner.title("info")).to eq("Important")
    end

    it "returns 'Success' for unknown types" do
      expect(flash_banner.title("unknown")).to eq("Success")
    end

    it "handles symbol input" do
      expect(flash_banner.title(:warning)).to eq("Important")
      expect(flash_banner.title(:success)).to eq("Success")
    end
  end

  describe "#success" do
    let(:flash) { ActionDispatch::Flash::FlashHash.new }
    let(:flash_banner) { described_class.new(flash:) }

    it "returns true when key is 'success'" do
      expect(flash_banner.success("success")).to be true
    end

    it "returns false when key is 'warning'" do
      expect(flash_banner.success("warning")).to be false
    end

    it "returns false when key is 'info'" do
      expect(flash_banner.success("info")).to be false
    end

    it "returns false when key is 'error'" do
      expect(flash_banner.success("error")).to be false
    end
  end

  describe "custom classes and html_attributes" do
    let(:flash) { ActionDispatch::Flash::FlashHash.new("success" => "Message") }
    let(:custom_classes) { %w[custom-class] }
    let(:custom_attributes) { { data: { test: "value" } } }

    before do
      render_inline(described_class.new(flash:, classes: custom_classes, html_attributes: custom_attributes))
    end

    it "accepts custom classes parameter" do
      # NOTE: These may not be applied in the current template implementation
      # but the component should accept them without error
      expect { described_class.new(flash:, classes: custom_classes) }.not_to raise_error
    end

    it "accepts custom html_attributes parameter" do
      expect { described_class.new(flash:, html_attributes: custom_attributes) }.not_to raise_error
    end
  end
end
