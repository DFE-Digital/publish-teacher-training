# frozen_string_literal: true

require "rails_helper"

RSpec.describe SearchTitlePresenter do
  subject(:title) { described_class.new(subjects:, location_name:, radius:, search_attributes:).to_s }

  let(:subjects) { [] }
  let(:location_name) { nil }
  let(:radius) { nil }
  let(:search_attributes) { {} }

  context "with 1 subject and no location" do
    let(:subjects) { ["Mathematics"] }

    it { is_expected.to eq("Mathematics courses in England") }
  end

  context "with 2 subjects and no location" do
    let(:subjects) { %w[Mathematics Physics] }

    it { is_expected.to eq("Mathematics and Physics courses in England") }
  end

  context "with 3+ subjects and no location" do
    let(:subjects) { %w[Mathematics Physics Chemistry] }

    it { is_expected.to eq("3 subjects in England") }
  end

  context "with no subjects and a location" do
    let(:location_name) { "Manchester" }
    let(:radius) { 10 }

    it { is_expected.to eq("Courses within 10 miles of Manchester") }
  end

  context "with 1 subject and a location" do
    let(:subjects) { ["Mathematics"] }
    let(:location_name) { "Manchester" }
    let(:radius) { 15 }

    it { is_expected.to eq("Mathematics courses within 15 miles of Manchester") }
  end

  context "with 2 subjects and a location" do
    let(:subjects) { %w[Mathematics Physics] }
    let(:location_name) { "Manchester" }
    let(:radius) { 15 }

    it { is_expected.to eq("Mathematics and Physics courses within 15 miles of Manchester") }
  end

  context "with 3+ subjects and a location" do
    let(:subjects) { %w[Mathematics Physics Chemistry] }
    let(:location_name) { "Manchester" }
    let(:radius) { 15 }

    it { is_expected.to eq("Courses within 15 miles of Manchester") }
  end

  context "with no subject/location but visa sponsorship" do
    let(:search_attributes) { { "can_sponsor_visa" => "true" } }

    it { is_expected.to eq("Courses with visa sponsorship") }
  end

  context "with no subject/location/visa but apprenticeship funding" do
    let(:search_attributes) { { "funding" => ["apprenticeship"] } }

    it { is_expected.to eq("Apprenticeship courses in England") }
  end

  context "with no subject/location/visa but salary funding" do
    let(:search_attributes) { { "funding" => ["salary"] } }

    it { is_expected.to eq("Salaried courses in England") }
  end

  context "with filters but no subject/location/visa/apprenticeship/salary" do
    let(:search_attributes) { { "level" => "primary", "send_courses" => "true" } }

    it { is_expected.to eq("Courses across England (2 filters applied)") }
  end

  context "with no filters at all" do
    it { is_expected.to eq("Courses across England") }
  end
end
