# frozen_string_literal: true

require "rails_helper"

RSpec.describe Find::SearchParams do
  describe ".permit" do
    it "permits scalar search parameters" do
      params = ActionController::Parameters.new(
        can_sponsor_visa: "true",
        location: "London",
        latitude: "51.5",
        longitude: "-0.1",
        radius: "10",
        level: "secondary",
        order: "distance",
        provider_code: "1BJ",
        provider_name: "UCL",
        send_courses: "true",
        engineers_teach_physics: "true",
        interview_location: "London",
        subject_code: "F1",
        subject_name: "Chemistry",
        minimum_degree_required: "two_one",
        formatted_address: "London, UK",
        return_to: "recent_searches",
        previous_location_category: "england",
      )

      permitted = described_class.permit(params)

      expect(permitted[:can_sponsor_visa]).to eq("true")
      expect(permitted[:location]).to eq("London")
      expect(permitted[:latitude]).to eq("51.5")
      expect(permitted[:longitude]).to eq("-0.1")
      expect(permitted[:radius]).to eq("10")
      expect(permitted[:level]).to eq("secondary")
      expect(permitted[:order]).to eq("distance")
      expect(permitted[:provider_code]).to eq("1BJ")
      expect(permitted[:provider_name]).to eq("UCL")
      expect(permitted[:send_courses]).to eq("true")
      expect(permitted[:engineers_teach_physics]).to eq("true")
      expect(permitted[:interview_location]).to eq("London")
      expect(permitted[:subject_code]).to eq("F1")
      expect(permitted[:subject_name]).to eq("Chemistry")
      expect(permitted[:minimum_degree_required]).to eq("two_one")
      expect(permitted[:formatted_address]).to eq("London, UK")
      expect(permitted[:return_to]).to eq("recent_searches")
      expect(permitted[:previous_location_category]).to eq("england")
    end

    it "permits array parameters" do
      params = ActionController::Parameters.new(
        subjects: %w[F1 G1],
        start_date: %w[september],
        study_types: %w[full_time part_time],
        qualifications: %w[qts pgce],
        funding: %w[fee salary apprenticeship],
      )

      permitted = described_class.permit(params)

      expect(permitted[:subjects]).to eq(%w[F1 G1])
      expect(permitted[:start_date]).to eq(%w[september])
      expect(permitted[:study_types]).to eq(%w[full_time part_time])
      expect(permitted[:qualifications]).to eq(%w[qts pgce])
      expect(permitted[:funding]).to eq(%w[fee salary apprenticeship])
    end

    it "permits funding as a scalar value" do
      params = ActionController::Parameters.new(funding: "fee")

      permitted = described_class.permit(params)

      expect(permitted[:funding]).to eq("fee")
    end

    it "permits excluded_courses with nested attributes" do
      params = ActionController::Parameters.new(
        excluded_courses: [{ provider_code: "1BJ", course_code: "X104" }],
      )

      permitted = described_class.permit(params)

      expect(permitted[:excluded_courses].first[:provider_code]).to eq("1BJ")
      expect(permitted[:excluded_courses].first[:course_code]).to eq("X104")
    end

    it "rejects unpermitted parameters" do
      params = ActionController::Parameters.new(
        evil: "hacker",
        location: "London",
      )

      permitted = described_class.permit(params)

      expect(permitted[:evil]).to be_nil
      expect(permitted[:location]).to eq("London")
    end

    context "when applications_open feature flag is active" do
      before { allow(FeatureFlag).to receive(:active?).with(:hide_applications_open_date).and_return(false) }

      it "permits applications_open" do
        params = ActionController::Parameters.new(applications_open: "true")

        permitted = described_class.permit(params)

        expect(permitted[:applications_open]).to eq("true")
      end
    end

    context "when hide_applications_open_date feature flag is active" do
      before { allow(FeatureFlag).to receive(:active?).with(:hide_applications_open_date).and_return(true) }

      it "does not permit applications_open" do
        params = ActionController::Parameters.new(applications_open: "true")

        permitted = described_class.permit(params)

        expect(permitted[:applications_open]).to be_nil
      end
    end
  end
end
