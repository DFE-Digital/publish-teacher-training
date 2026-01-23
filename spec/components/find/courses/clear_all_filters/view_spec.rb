require "rails_helper"

RSpec.describe Find::Courses::ClearAllFilters::View, type: :component do
  it "renders when there are active filters" do
    active_filters = [double]
    result = render_inline(described_class.new(active_filters:, position: :bottom))

    expect(result.text.chomp).to eq("Clear all")

    link = result.css("a").first
    expect(link).to be_present
    expect(link[:href]).to eq("/results?utm_medium=clear_all_filters_bottom&utm_source=results")
  end

  it "renders nothing when there are no active filters" do
    result = render_inline(described_class.new(active_filters: [], position: :top))

    expect(result.text).to eq("")
  end
end
