# frozen_string_literal: true

require "rails_helper"

RSpec.describe Find::CreateEmailAlertService do
  describe ".call" do
    let(:candidate) { create(:candidate) }

    context "when creating a new email alert" do
      it "creates an EmailAlert with denormalized and JSONB attributes" do
        params = {
          subjects: %w[F1 C1],
          longitude: "-1.5",
          latitude: "53.0",
          radius: "20",
          location: "Manchester",
          funding: "salary",
          level: "secondary",
        }

        result = described_class.call(candidate:, search_params: params)

        expect(result).to be_a(EmailAlert)
        expect(result).to be_persisted
        expect(result.subjects).to eq(%w[C1 F1]) # sorted
        expect(result.longitude).to eq(-1.5)
        expect(result.latitude).to eq(53.0)
        expect(result.radius).to eq(20)
        expect(result.location_name).to eq("Manchester")
        expect(result.search_attributes).to include("funding" => "salary", "level" => "secondary")
      end

      it "sorts subjects array" do
        result = described_class.call(
          candidate:,
          search_params: { subjects: %w[Z1 A1 M1] },
        )

        expect(result.subjects).to eq(%w[A1 M1 Z1])
      end

      it "strips blank subjects" do
        result = described_class.call(
          candidate:,
          search_params: { subjects: ["C1", "", nil, "F1"] },
        )

        expect(result.subjects).to eq(%w[C1 F1])
      end

      it "only stores permitted keys in search_attributes" do
        result = described_class.call(
          candidate:,
          search_params: { subjects: %w[C1], funding: "salary", page: "2", sortby: "distance" },
        )

        expect(result.search_attributes).to eq("funding" => "salary")
        expect(result.search_attributes).not_to have_key("page")
        expect(result.search_attributes).not_to have_key("sortby")
      end

      it "strips blank values from search_attributes" do
        result = described_class.call(
          candidate:,
          search_params: { subjects: %w[C1], funding: "", level: "secondary" },
        )

        expect(result.search_attributes).to eq("level" => "secondary")
      end
    end

    context "when location_name" do
      it "uses location param when present" do
        result = described_class.call(
          candidate:,
          search_params: { subjects: %w[C1], location: "London" },
        )

        expect(result.location_name).to eq("London")
      end

      it "falls back to formatted_address when location is absent" do
        result = described_class.call(
          candidate:,
          search_params: { subjects: %w[C1], formatted_address: "Birmingham, UK" },
        )

        expect(result.location_name).to eq("Birmingham, UK")
      end

      it "is nil when neither location nor formatted_address provided" do
        result = described_class.call(
          candidate:,
          search_params: { subjects: %w[C1] },
        )

        expect(result.location_name).to be_nil
      end
    end

    context "when candidate creates multiple alerts" do
      it "allows duplicate filter combinations (no dedup)" do
        params = { subjects: %w[C1], funding: "salary" }

        first = described_class.call(candidate:, search_params: params)
        second = described_class.call(candidate:, search_params: params)

        expect(first.id).not_to eq(second.id)
        expect(candidate.email_alerts.count).to eq(2)
      end
    end

    context "when saving fails" do
      before do
        allow(Sentry).to receive(:capture_exception)
      end

      it "captures the exception and returns nil" do
        email_alerts = candidate.email_alerts
        allow(email_alerts).to receive(:create!).and_raise(ActiveRecord::RecordInvalid.new(EmailAlert.new))
        allow(candidate).to receive(:email_alerts).and_return(email_alerts)

        result = described_class.call(candidate:, search_params: { subjects: %w[C1] })

        expect(result).to be_nil
        expect(Sentry).to have_received(:capture_exception).once
      end
    end

    context "with various param types" do
      it "handles string-keyed params" do
        result = described_class.call(
          candidate:,
          search_params: { "subjects" => %w[C1], "funding" => "salary" },
        )

        expect(result).to be_persisted
        expect(result.subjects).to eq(%w[C1])
      end

      it "handles ActionController::Parameters" do
        params = ActionController::Parameters.new(subjects: %w[C1], funding: "salary").permit!

        result = described_class.call(candidate:, search_params: params)

        expect(result).to be_persisted
        expect(result.subjects).to eq(%w[C1])
      end
    end
  end
end
