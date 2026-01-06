require "rails_helper"

RSpec.describe Find::Courses::ActiveFilters::View, type: :component do
  subject(:result) do
    render_inline(
      described_class.new(active_filters:, search_params:),
    ).text.gsub(/\r?\n/, " ").squeeze(" ").strip
  end

  context "when there are active filters" do
    let(:active_filters) do
      [
        Courses::ActiveFilter.new(
          id: :send_courses,
          raw_value: true,
          value: true,
          remove_params: { send_courses: nil },
        ),
      ]
    end
    let(:search_params) { { send_courses: true } }

    it "renders the correct content" do
      expect(result).to include("Courses with a SEND specialism")
    end
  end

  context "when there are no active filters" do
    let(:active_filters) { [] }
    let(:search_params) {}

    it "renders the correct content" do
      expect(result).to eq("")
    end
  end
end
