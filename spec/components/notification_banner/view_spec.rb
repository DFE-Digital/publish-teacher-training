# frozen_string_literal: true

require "rails_helper"

module NotificationBanner
  describe View do
    alias_method :component, :page

    context "with no arguments" do
      before { render_inline(View.new) }

      it "adds the default class" do
        expect(component).to have_selector(".govuk-notification-banner")
      end

      it "doesn't add the success class" do
        expect(component).not_to have_selector(".govuk-notification-banner--success")
      end

      it "has a default title of 'Important'" do
        expect(component).to have_text("Important")
      end

      it "has a default role of 'region'" do
        expect(banner["role"]).to eq("region")
      end

      it "has a default data attribute of data-module=govuk-notification-banner" do
        expect(banner["data-module"]).to eq("govuk-notification-banner")
      end

      it "doesn't disable autofocus" do
        expect(banner["data-disable-auto-focus"]).to be_nil
      end
    end

    context "when type is success" do
      before { render_inline(View.new(type: :success)) }

      it "adds the success type class" do
        expect(component).to have_selector(".govuk-notification-banner--success")
      end

      it "has a default title of 'Success'" do
        expect(component).to have_text("Success")
      end

      it "has a default role of 'alert'" do
        expect(banner["role"]).to eq("alert")
      end
    end

    it "supports custom classes on the parent container" do
      render_inline(View.new(classes: "test-css-class"))
      expect(component).to have_selector(".test-css-class")
    end

    it "supports custom title and text" do
      render_inline(View.new(title_text: "title", text: "text"))
      expect(component).to have_text("title")
      expect(component).to have_text("text")
    end

    it "supports a custom role" do
      render_inline(View.new(role: "role"))
      expect(banner["role"]).to eq("role")
    end

    it "supports a custom id on the title element and sets the ariaLabelledBy" do
      render_inline(View.new(title_id: "test-id"))
      expect(component).to have_selector(".govuk-notification-banner__title#test-id")
      expect(banner["aria-labelledby"]).to eq "test-id"
    end

    it "supports disabling autofocus" do
      render_inline(View.new(disable_auto_focus: true))
      expect(banner["data-disable-auto-focus"]).to eq("true")
    end

    def banner
      page.find(".govuk-notification-banner")
    end
  end
end
