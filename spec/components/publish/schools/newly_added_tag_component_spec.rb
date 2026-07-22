# frozen_string_literal: true

require "rails_helper"

RSpec.describe Publish::Schools::NewlyAddedTagComponent, type: :component do
  it "does not render for provider school rows from the new model" do
    provider_school = create(:provider_school)

    render_inline(described_class.new(school: provider_school))

    expect(page).not_to have_css(".newly-added-tag")
  end
end
