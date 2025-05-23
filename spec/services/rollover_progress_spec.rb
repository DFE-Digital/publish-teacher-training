require "rails_helper"

RSpec.describe RolloverProgress, type: :model do
  let(:target_cycle) { create(:recruitment_cycle, year: "2026", application_start_date: Date.new(2025, 9, 1)) }
  let(:previous_target_cycle) { RecruitmentCycle.current }
  let(:rollover_progress) { described_class.new(target_cycle:) }

  let(:provider_with_own_course) { create(:provider, recruitment_cycle: previous_target_cycle) }
  let(:training_provider) { create(:provider, recruitment_cycle: previous_target_cycle) }
  let(:provider_with_accredited_course) { create(:provider, recruitment_cycle: previous_target_cycle) }
  let(:provider_with_withdrawn_course) { create(:provider, recruitment_cycle: previous_target_cycle) }
  let(:provider_with_only_draft_courses) { create(:provider, recruitment_cycle: previous_target_cycle) }
  let(:provider_without_courses) { create(:provider, recruitment_cycle: previous_target_cycle) }
  let(:rolled_over_provider) do
    create(:provider, recruitment_cycle: target_cycle, created_at: 1.day.before(target_cycle.application_start_date))
  end
  let(:new_provider) do
    create(:provider, recruitment_cycle: target_cycle, created_at: 1.day.after(target_cycle.application_start_date))
  end

  before do
    mid_cycle = Time.zone.local(2025, 5, 23, 10, 0, 0)
    Timecop.travel(mid_cycle)
  end

  describe "#initialize" do
    it "calculates previous_target_cycle" do
      expect(rollover_progress.previous_target_cycle.attributes).to eq(previous_target_cycle.attributes)
    end
  end

  describe "#status" do
    context "when target cycle is upcoming" do
      before { allow(target_cycle).to receive(:upcoming?).and_return(true) }

      it "returns in_progress status with yellow colour" do
        expect(rollover_progress.status).to eq({
          text: "In progress",
          colour: "yellow",
        })
      end
    end

    context "when target cycle is finished" do
      before { allow(target_cycle).to receive(:upcoming?).and_return(false) }

      it "returns finished status with green colour" do
        expect(rollover_progress.status).to eq({
          text: "Finished",
          colour: "green",
        })
      end
    end
  end

  describe "#summary" do
    context "when previous_target_cycle is nil" do
      before do
        allow(RecruitmentCycle).to receive(:find_by).with(year: 2025).and_return(nil)
      end

      it "returns no_previous_cycle translation" do
        expect(rollover_progress.summary).to eq(
          I18n.t("activemodel.attributes.rollover_progress.no_previous_cycle"),
        )
      end
    end

    context "when previous_target_cycle is present" do
      before do
        given_we_have_providers_and_courses_on_previous_target_cycle
        given_we_have_rolled_over_providers
      end

      it "returns the summary translation with counts" do
        expect(rollover_progress.summary).to eq("1 of 4 providers (25.0%)")
      end
    end
  end

  describe "#remaining_to_rollover_count" do
    before do
      given_we_have_providers_and_courses_on_previous_target_cycle
      given_we_have_rolled_over_providers
    end

    it "calculates remaining providers to rollover" do
      expect(rollover_progress.remaining_to_rollover_count).to eq(3)
    end
  end

  describe "#rollover_percentage" do
    context "when total eligible count is zero" do
      it "returns 0" do
        expect(rollover_progress.rollover_percentage).to eq(0)
      end
    end

    context "when rolled over count is zero" do
      before do
        given_we_have_providers_and_courses_on_previous_target_cycle
      end

      it "returns 0" do
        expect(rollover_progress.rollover_percentage).to eq(0)
      end
    end

    context "when calculating percentage" do
      before do
        given_we_have_providers_and_courses_on_previous_target_cycle
        given_we_have_rolled_over_providers
      end

      it "calculates percentage correctly" do
        expect(rollover_progress.rollover_percentage).to eq(25.0)
      end
    end
  end

  describe "#providers_without_published_courses" do
    before do
      given_we_have_providers_and_courses_on_previous_target_cycle
    end

    it "returns providers without published courses" do
      expect(
        rollover_progress.providers_without_published_courses,
      ).to match_collection(
        [provider_with_only_draft_courses, provider_without_courses],
        attribute_names: %w[provider_name provider_code],
      )
    end
  end

  describe "#total_eligible_providers" do
    before do
      given_we_have_providers_and_courses_on_previous_target_cycle
    end

    it "includes providers with own rollable courses and accredited rollable courses" do
      expect(rollover_progress.total_eligible_providers).to match_collection(
        [
          provider_with_own_course,
          training_provider,
          provider_with_accredited_course,
          provider_with_withdrawn_course,
        ],
        attribute_names: %w[provider_code],
      )
    end
  end

  describe "#rolled_over_providers" do
    before do
      given_we_have_rolled_over_providers
    end

    it "includes providers created before application start date" do
      expect(
        rollover_progress.rolled_over_providers,
      ).to match_collection(
        [rolled_over_provider],
        attribute_names: %w[provider_code],
      )
    end
  end

  describe "delegated count methods" do
    before do
      given_we_have_providers_and_courses_on_previous_target_cycle
      given_we_have_rolled_over_providers
    end

    it "delegates providers_without_published_courses_count" do
      expect(rollover_progress.providers_without_published_courses_count).to eq(2)
    end

    it "delegates total_eligible_providers_count" do
      expect(rollover_progress.total_eligible_providers_count).to eq(4)
    end

    it "delegates rolled_over_providers_count" do
      expect(rollover_progress.rolled_over_providers_count).to eq(1)
    end
  end

private

  def given_we_have_providers_and_courses_on_previous_target_cycle
    provider_with_own_course
    training_provider
    provider_with_accredited_course
    provider_with_withdrawn_course
    provider_with_only_draft_courses
    provider_without_courses

    create(:course, :published, provider: provider_with_own_course)
    create(:course, :published, provider: training_provider, accredited_provider_code: provider_with_accredited_course.provider_code)
    create(:course, :draft_enrichment, provider: provider_with_only_draft_courses)
    create(:course, :withdrawn, provider: provider_with_withdrawn_course)
  end

  def given_we_have_rolled_over_providers
    rolled_over_provider
    new_provider
  end
end
