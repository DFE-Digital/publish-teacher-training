# frozen_string_literal: true

require "rails_helper"

RSpec.describe Users::SortLinksComponent, type: :component do
  it "shows name as the selected sort" do
    render_inline(described_class.new(sort: "name", name_path: "/users", last_signed_in_path: "/users?sort=last_signed_in"))

    expect(page).to have_css("strong", text: "Name A to Z")
    expect(page).to have_link("Most recently signed in", href: "/users?sort=last_signed_in")
    expect(page).not_to have_link("Name A to Z")
  end

  it "shows most recently signed in as the selected sort" do
    render_inline(described_class.new(sort: "last_signed_in", name_path: "/users", last_signed_in_path: "/users?sort=last_signed_in"))

    expect(page).to have_css("strong", text: "Most recently signed in")
    expect(page).to have_link("Name A to Z", href: "/users")
    expect(page).not_to have_link("Most recently signed in")
  end
end
