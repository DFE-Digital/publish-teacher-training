# frozen_string_literal: true

require "rails_helper"

RSpec.describe Publish::Courses::TableComponent, type: :component do
  subject(:render_component) { render_inline(described_class.new(courses:, provider:)) }

  let(:provider) { create(:provider) }
  let!(:course) { create(:course, :published_postgraduate, provider:) }
  let(:courses) { Publish::Courses::Query.call(provider: provider.reload).map(&:decorate) }

  it "renders the Course, Course information and Status column headers" do
    render_component

    headers = page.all(".govuk-table__header").map(&:text)
    expect(headers).to eq(["Course", "Course information", "Status"])
  end

  it "renders a row for each course" do
    render_component

    expect(page).to have_css("tbody .govuk-table__row", count: 1)
    expect(page).to have_text(course.name_and_code)
  end
end
