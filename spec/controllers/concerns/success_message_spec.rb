# frozen_string_literal: true

require "rails_helper"

RSpec.describe SuccessMessage do
  subject(:helper) { test_class.new }

  let(:test_class) do
    Class.new do
      include SuccessMessage

      attr_accessor :course, :flash

      def initialize
        @flash = {}
      end
    end
  end

  describe "#course_updated_message" do
    context "when the course is published" do
      before { helper.course = create(:course, :published) }

      it "sets a success_with_body flash with the live changes message" do
        helper.course_updated_message("Interview process")

        expect(helper.flash[:success_with_body]).to eq(
          "title" => "Interview process updated",
          "body" => "These changes are now live.",
        )
        expect(helper.flash[:success]).to be_nil
      end
    end

    context "when the course is not published" do
      before { helper.course = create(:course, :draft_enrichment) }

      it "sets a simple success flash without the live changes message" do
        helper.course_updated_message("Interview process")

        expect(helper.flash[:success]).to eq("Interview process updated")
        expect(helper.flash[:success_with_body]).to be_nil
      end
    end

    context "when there is no course" do
      before { helper.course = nil }

      it "sets a simple success flash" do
        helper.course_updated_message("Study site")

        expect(helper.flash[:success]).to eq("Study site updated")
        expect(helper.flash[:success_with_body]).to be_nil
      end
    end
  end
end
