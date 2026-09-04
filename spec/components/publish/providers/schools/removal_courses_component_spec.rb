# frozen_string_literal: true

require "rails_helper"

RSpec.describe Publish::Providers::Schools::RemovalCoursesComponent, type: :component do
  subject(:rendered) { render_inline(described_class.new(courses: [course], provider:, link_to_course:)) }

  let(:provider) { create(:provider) }
  let(:course) do
    create(
      :course,
      provider:,
      name: "Primary",
      course_code: "X123",
      funding: "fee",
      start_date: Time.zone.local(provider.recruitment_cycle.year.to_i, 9, 1),
    )
  end
  let(:link_to_course) { false }

  it "renders the course name, code and summary line" do
    expect(rendered).to have_css("p[class~='govuk-!-font-weight-bold']", text: "Primary (X123)")
    expect(rendered).to have_css(
      "span.govuk-hint",
      text: "Fee-paying, QTS with PGCE, Full time, September #{provider.recruitment_cycle.year}",
    )
    expect(rendered).to have_no_link("Primary (X123)")
  end

  context "when linking to the course" do
    let(:link_to_course) { true }

    it "links the course name to the description tab in a new tab" do
      expect(rendered).to have_no_css("h2")
      expect(rendered).to have_link("Primary (X123)")
      link = rendered.css("a").find { |anchor| anchor.text.include?("Primary (X123)") }
      expect(link[:href]).to include("/courses/#{course.course_code}")
      expect(link[:target]).to eq("_blank")
      expect(link.text).to include("(opens in a new tab)")
    end
  end
end
