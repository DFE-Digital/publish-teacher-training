# frozen_string_literal: true

require "rails_helper"

RSpec.describe Find::RecordRecentSearchService do
  describe ".call" do
    let(:candidate) { create(:candidate) }

    context "when candidate is nil" do
      it "returns nil" do
        result = described_class.call(candidate: nil, search_params: { subjects: %w[C1] })
        expect(result).to be_nil
      end
    end

    context "when creating a new recent search" do
      it "creates a RecentSearch with denormalized and JSONB attributes" do
        params = {
          subjects: %w[F1 C1],
          longitude: "-1.5",
          latitude: "53.0",
          radius: "20",
          funding: "salary",
          level: "secondary",
        }

        result = described_class.call(candidate:, search_params: params)

        expect(result).to be_a(RecentSearch)
        expect(result).to be_persisted
        expect(result.subjects).to eq(%w[C1 F1]) # sorted
        expect(result.longitude).to eq(-1.5)
        expect(result.latitude).to eq(53.0)
        expect(result.radius).to eq(20)
        expect(result.search_attributes).to include("funding" => "salary", "level" => "secondary")
      end

      it "sorts subjects array for consistent deduplication" do
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

    context "when a matching search already exists" do
      it "updates search_attributes and touches updated_at" do
        existing = create(
          :recent_search,
          candidate:,
          subjects: %w[C1 F1],
          longitude: -1.5,
          latitude: 53.0,
          radius: 20,
          search_attributes: { "level" => "secondary" },
          updated_at: 2.days.ago,
        )

        result = described_class.call(
          candidate:,
          search_params: {
            subjects: %w[F1 C1], # different order, same after sort
            longitude: "-1.5",
            latitude: "53.0",
            radius: "20",
            funding: "salary",
          },
        )

        expect(result.id).to eq(existing.id)
        expect(result.search_attributes).to include("funding" => "salary")
        expect(result.updated_at).to be > 1.day.ago
      end

      it "does not create a duplicate record" do
        create(
          :recent_search,
          candidate:,
          subjects: %w[C1],
          longitude: nil,
          latitude: nil,
          radius: nil,
        )

        expect {
          described_class.call(candidate:, search_params: { subjects: %w[C1], level: "primary" })
        }.not_to change(RecentSearch, :count)
      end
    end

    context "when a discarded search exists with the same attributes" do
      it "creates a new record (does not reuse discarded)" do
        discarded = create(
          :recent_search,
          candidate:,
          subjects: %w[C1],
        )
        discarded.discard

        result = described_class.call(candidate:, search_params: { subjects: %w[C1] })

        expect(result.id).not_to eq(discarded.id)
        expect(result).to be_persisted
        expect(result).not_to be_discarded
      end
    end

    context "when saving fails" do
      before do
        allow(Sentry).to receive(:capture_exception)
      end

      it "captures the exception and returns nil" do
        allow(candidate.recent_searches).to receive(:create!).and_raise(ActiveRecord::RecordInvalid.new(RecentSearch.new))

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
