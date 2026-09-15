# frozen_string_literal: true

require "rails_helper"

describe Publish::Courses::Schools::BulkUpdateScopeForm do
  let(:provider) { create(:provider) }
  let(:course) { create(:course, :primary, provider:) }

  it "is invalid when no scope has been chosen" do
    form = described_class.new(course:, scope: nil)

    expect(form).not_to be_valid
    expect(form.errors[:scope]).to eq(["Select what courses you want to apply this change to"])
  end

  it "is invalid for a scope the course was never offered" do
    form = described_class.new(course:, scope: "secondary")

    expect(form).not_to be_valid
    expect(form.errors[:scope]).to be_present
  end

  it "is valid for a scope the course offers" do
    expect(described_class.new(course:, scope: "all")).to be_valid
  end

  it "lists the scopes the course offers, for the radios to render" do
    expect(described_class.new(course:).scopes.map(&:token))
      .to eq(%w[only_this_course funding subject all])
  end
end
