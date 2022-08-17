require "rails_helper"

describe Courses::ContentStatusService do
  let(:service) { described_class.new }
  let(:execute_service) { service.execute(enrichment:, recruitment_cycle:) }
  let(:recruitment_cycle) { find_or_create(:recruitment_cycle) }

  context "when the enrichment parameter is nil" do
    let(:enrichment) { nil }

    context "and belongs to the next recruitment" do
      let(:recruitment_cycle) { find_or_create(:recruitment_cycle, :next) }

      it "returns rolled over" do
        expect(execute_service).to eq :rolled_over
      end
    end

    context "and does not belong to the next recruitment cycle" do
      it "returns draft" do
        expect(execute_service).to eq :draft
      end
    end
  end

  context "when the enrichment has been published" do
    let(:enrichment) { build(:course_enrichment, :published) }

    it "returns published" do
      expect(execute_service).to eq :published
    end
  end

  context "when the enrichment has been withdrawn" do
    let(:enrichment) { build(:course_enrichment, :withdrawn) }

    it "returns withdrawn" do
      expect(execute_service).to eq :withdrawn
    end
  end

  context "when the enrichment has been been published previously" do
    let(:enrichment) { build(:course_enrichment, :subsequent_draft) }

    it "returns published_with_unpublished_changes" do
      expect(execute_service).to eq :published_with_unpublished_changes
    end
  end

  context "when the enrichment has been rolled over" do
    let(:enrichment) { build(:course_enrichment, :rolled_over) }

    it "returns rolled over" do
      expect(execute_service).to eq :rolled_over
    end
  end

  context "when the enrichment is a draft enrichment" do
    let(:enrichment) { build(:course_enrichment) }

    it "returns draft" do
      expect(execute_service).to eq :draft
    end
  end
end
