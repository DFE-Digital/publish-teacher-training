# frozen_string_literal: true

require "rails_helper"

describe Find::OneLoginBannerComponent do
  alias_method :component, :page

  context "with no arguments" do
    before { render_inline(described_class.new) }

    it "adds the default class" do
      expect(component).to have_css(".govuk-notification-banner")
    end

    it "has title of 'Important'" do
      expect(component).to have_text("Important")
    end

    it "has the correct content" do
      expect(component).to have_text(/You must\s*sign in\s*to visit that page\./)
      expect(component).to have_button("sign in")
      expect(component).to have_css(".govuk-notification-banner__heading")
    end

    it "posts to the correct one login path" do
      form = component.find("form.govuk-notification-banner__heading")

      expect(form[:action]).to eq("/auth/one-login") if Settings.one_login.enabled
      expect(form[:action]).to eq("/auth/find-developer") unless Settings.one_login.enabled
      expect(form[:method]).to eq("post")
      expect(component).to have_selector("form input[name='authenticity_token']", visible: :hidden)
    end

    it "has a sign in button" do
      button = component.find("form.govuk-notification-banner__heading button")
      expect(button.text).to eq("sign in")
      expect(button[:type]).to eq("submit")
    end

    context "when the user has tried to save a course / the reason is :save_course" do
      before { render_inline(described_class.new(reason: :save_course)) }

      it "has the correct content" do
        expect(component).to have_text(/You must\s*sign in\s*to save a course\./)
      end
    end

    context "when the user has NOT tried to save a course but tried to access another authenticated page / reason is :general" do
      before { render_inline(described_class.new(reason: :general)) }

      it "has the correct content" do
        expect(component).to have_text(/You must\s*sign in\s*to visit that page\./)
      end
    end
  end
end
