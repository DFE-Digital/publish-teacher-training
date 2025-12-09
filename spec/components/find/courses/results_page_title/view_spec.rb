# frozen_string_literal: true

require "rails_helper"

RSpec.describe Find::Courses::ResultsPageTitle::View, type: :component do
  subject(:result) do
    render_inline(
      described_class.new(courses_count:, address:),
    ).text.strip
  end

  context "when search by location" do
    let(:address) { Geolocation::Address.new(formatted_address: "London, UK") }

    context "when no results" do
      let(:courses_count) { 0 }

      it "render no results" do
        expect(result).to eq("No courses found")
      end
    end

    context "when 1 result" do
      let(:courses_count) { 1 }

      it "render page title" do
        expect(result).to eq("1 course in London")
      end
    end

    context "when many results" do
      let(:courses_count) { 10 }

      it "render page title" do
        expect(result).to eq("10 courses in London")
      end
    end
  end

  context "when is not search by location" do
    let(:address) { Geolocation::Address.new(formatted_address: nil) }

    context "when no results" do
      let(:courses_count) { 0 }

      it "render no results" do
        expect(result).to eq("No courses found")
      end
    end

    context "when 1 result" do
      let(:courses_count) { 1 }

      it "render page title" do
        expect(result).to eq("1 course found")
      end
    end

    context "when many results" do
      let(:courses_count) { 10 }

      it "render page title" do
        expect(result).to eq("10 courses found")
      end
    end
  end
end
