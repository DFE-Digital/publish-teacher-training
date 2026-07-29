# frozen_string_literal: true

require "rails_helper"

RSpec.describe Publish::ConfirmLiveChanges do
  subject(:helper) { test_class.new }

  let(:test_class) do
    Class.new do
      include Publish::ConfirmLiveChanges
      include Rails.application.routes.url_helpers

      attr_accessor :course, :params, :request

      def initialize
        @params = {}
        @request = Struct.new(:path, :request_method).new("/update", "PATCH")
        @rendered = false
      end

      def render(*)
        @rendered = true
        :rendered_confirmation
      end

      def rendered?
        @rendered
      end

      def default_url_options
        { host: "test.host" }
      end
    end
  end

  describe "#require_live_changes_confirmation?" do
    context "when the course is published and confirm_publish is not set" do
      before do
        helper.course = create(:course, :published)
        helper.params = {}
      end

      it { expect(helper.send(:require_live_changes_confirmation?)).to be true }
    end

    context "when the course is published and confirm_publish is true" do
      before do
        helper.course = create(:course, :published)
        helper.params = { confirm_publish: "true" }
      end

      it { expect(helper.send(:require_live_changes_confirmation?)).to be false }
    end

    context "when the course is a draft" do
      before do
        helper.course = create(:course, :draft_enrichment)
        helper.params = {}
      end

      it { expect(helper.send(:require_live_changes_confirmation?)).to be false }
    end
  end

  describe "#confirm_live_changes_if_required!" do
    let(:form_class) do
      Class.new do
        const_set(:FIELDS, %i[course_length])

        attr_accessor :course_length

        def initialize(course_length:)
          @course_length = course_length
        end
      end
    end
    let(:form) { form_class.new(course_length: "TwoYears") }

    context "when confirmation is required" do
      before do
        helper.course = create(:course, :published)
        helper.params = {}
      end

      it "renders the interstitial and returns true" do
        result = helper.send(
          :confirm_live_changes_if_required!,
          section_name: "Course length",
          form:,
          form_param_key: :publish_course_length_form,
        )

        expect(result).to be true
        expect(helper.rendered?).to be true
        expect(helper.instance_variable_get(:@confirm_live_changes)).to have_attributes(
          section_name: "Course length",
          form_param_key: :publish_course_length_form,
          fields: %i[course_length],
          update_path: "/update",
          back_path: "/update",
          method: :patch,
        )
      end
    end

    context "when confirmation is not required" do
      before do
        helper.course = create(:course, :draft_enrichment)
        helper.params = {}
      end

      it "returns false and does not render" do
        result = helper.send(
          :confirm_live_changes_if_required!,
          section_name: "Course length",
          form:,
          form_param_key: :publish_course_length_form,
        )

        expect(result).to be false
        expect(helper.rendered?).to be false
      end
    end
  end
end
