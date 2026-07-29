# frozen_string_literal: true

require "rails_helper"

RSpec.describe Publish::Courses::ConfirmLiveChangesView do
  subject(:view) do
    described_class.new(
      course:,
      section_name:,
      form:,
      form_param_key:,
      fields:,
      update_path: "/update",
      back_path: "/back",
      cancel_path: "/cancel",
      method: :patch,
      extra_hidden_fields:,
    )
  end

  let(:course) { build(:course, name: "Primary", course_code: "X123") }
  let(:section_name) { "What you will study" }
  let(:form_param_key) { :publish_fields_what_you_will_study_form }
  let(:fields) { %i[theoretical_training_activities subjects] }
  let(:extra_hidden_fields) { { "#{form_param_key}[goto_preview]" => "true" } }
  let(:form) do
    Struct.new(:theoretical_training_activities, :subjects).new(
      "Seminars and workshops",
      %w[maths english],
    )
  end

  describe "#page_title" do
    it "returns the translated page title for the section" do
      expect(view.page_title).to eq(
        "Are you sure you want to publish your changes to 'What you will study'?",
      )
    end
  end

  describe "#heading" do
    it "returns the translated heading for the section" do
      expect(view.heading).to eq(
        "Are you sure you want to publish your changes to 'What you will study'?",
      )
    end
  end

  describe "#body" do
    it "returns the translated body" do
      expect(view.body).to eq("Your changes will go live immediately.")
    end
  end

  describe "#continue_label" do
    it "returns the translated continue label" do
      expect(view.continue_label).to eq("Continue and publish changes")
    end
  end

  describe "#course_name_and_code" do
    it "returns the course name and code" do
      expect(view.course_name_and_code).to eq("Primary (X123)")
    end
  end

  describe "#fields" do
    context "when a single field is passed" do
      let(:fields) { :theoretical_training_activities }

      it "wraps the field in an array" do
        expect(view.fields).to eq(%i[theoretical_training_activities])
      end
    end
  end

  describe "#each_hidden_field" do
    it "yields scalar fields, array fields, and extra hidden fields" do
      expect { |block| view.each_hidden_field(&block) }.to yield_successive_args(
        ["#{form_param_key}[theoretical_training_activities]", "Seminars and workshops"],
        ["#{form_param_key}[subjects][]", "maths"],
        ["#{form_param_key}[subjects][]", "english"],
        ["#{form_param_key}[goto_preview]", "true"],
      )
    end
  end
end
