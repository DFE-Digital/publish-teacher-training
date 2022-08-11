# frozen_string_literal: true

require "rails_helper"

RSpec.describe PageTitle::View do
  before do
    allow(I18n).to receive(:t).with("service_name.publish").and_return("Cool Service")
  end

  context "given a string that is not in the format of an i18n path" do
    it "constructs a page title using the provided value" do
      component = PageTitle::View.new(title: "Some title")
      page_title = component.build_page_title
      expect(page_title).to eq("Some title - Cool Service - GOV.UK")
    end
  end

  context "when has_errors is true" do
    it "constructs a page title value with an error" do
      component = PageTitle::View.new(title: "Some title", has_errors: true)
      page_title = component.build_page_title
      expect(page_title).to eq("Error: Some title - Cool Service - GOV.UK")
    end
  end

  context "given an i18n key format" do
    before do
      allow(I18n).to receive(:t).with("components.page_titles.sign_in.index").and_return("Sign in")
    end

    it "constructs a page title value" do
      component = PageTitle::View.new(title: "sign_in.index")
      page_title = component.build_page_title
      expect(page_title).to eq("Sign in - Cool Service - GOV.UK")
    end
  end
end
