# frozen_string_literal: true

require "rails_helper"

RSpec.describe ClosedSchoolTagComponent, type: :component do
  it "renders a Closed tag when the school is closed" do
    render_inline(described_class.new(closed: true))

    expect(page).to have_css(".govuk-tag", text: "Closed")
  end

  it "does not render when the school is not closed" do
    render_inline(described_class.new(closed: false))

    expect(page).to have_no_css(".govuk-tag")
  end
end
