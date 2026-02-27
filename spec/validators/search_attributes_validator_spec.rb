# frozen_string_literal: true

require "rails_helper"

describe SearchAttributesValidator do
  subject { model }

  before do
    stub_const("Validatable", Class.new).class_eval do
      include ActiveModel::Validations
      attr_accessor :search_attributes

      validates :search_attributes, search_attributes: true
    end

    subject.validate
  end

  let(:model) do
    model = Validatable.new
    model.search_attributes = attrs
    model
  end

  context "with permitted keys only" do
    let(:attrs) { { "funding" => "salary", "level" => "secondary" } }

    it { is_expected.to be_valid }
  end

  context "with interview_location key" do
    let(:attrs) { { "interview_location" => "online" } }

    it { is_expected.to be_valid }
  end

  context "with empty hash" do
    let(:attrs) { {} }

    it { is_expected.to be_valid }
  end

  context "with nil" do
    let(:attrs) { nil }

    it { is_expected.to be_valid }
  end

  context "with unknown keys" do
    let(:attrs) { { "funding" => "salary", "bogus_key" => "value" } }

    it { is_expected.to be_invalid }

    it "includes unknown key names in the error message" do
      expect(model.errors[:search_attributes].first).to include("bogus_key")
    end
  end
end
