require "rails_helper"

RSpec.describe RolloverProgressQuery, type: :model do
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
  let(:published_course) do
    create(:course, :published, provider: provider_with_own_course)
  end
  let(:rolled_over_published_course) do
    create(:course, provider: rolled_over_provider, course_code: published_course.course_code)
  end
  let(:accredited_course) do
    create(:course, :published, provider: training_provider, accredited_provider_code: provider_with_accredited_course.provider_code)
  end
  let(:rolled_over_accredited_course) do
    create(:course, provider: new_provider, accredited_provider_code: rolled_over_provider.provider_code, course_code: accredited_course.course_code)
  end
  let(:draft_course) do
    create(:course, :draft_enrichment, provider: provider_with_only_draft_courses)
  end
  let(:withdrawn_course) do
    create(:course, :withdrawn, provider: provider_with_withdrawn_course)
  end
  let(:rolled_over_withdrawn_course) do
    create(:course, provider: new_provider, course_code: withdrawn_course.course_code)
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

  describe "#eligible_providers" do
    before do
      given_we_have_providers_and_courses_on_previous_target_cycle
    end

    it "includes providers with own rollable courses and accredited rollable courses" do
      expect(rollover_progress.eligible_providers).to match_collection(
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

  describe "#eligible_courses" do
    before do
      given_we_have_providers_and_courses_on_previous_target_cycle
    end

    it "includes providers with own rollable courses and accredited rollable courses" do
      expect(rollover_progress.eligible_courses).to match_collection(
        [published_course, accredited_course, withdrawn_course],
        attribute_names: %w[course_code],
      )
    end
  end

  describe "#rolled_over_courses" do
    before do
      given_we_have_rolled_over_providers
      given_we_have_rolled_over_courses
    end

    it "includes courses created on rollover" do
      expect(
        rollover_progress.rolled_over_courses,
      ).to match_collection(
        [rolled_over_published_course, rolled_over_accredited_course, rolled_over_withdrawn_course],
        attribute_names: %w[course_code],
      )
    end
  end

  describe "#eligible_partnerships" do
    let(:accredited_provider) { create(:provider, :accredited_provider) }
    let(:rollable_partnership_one) do
      create(
        :provider_partnership,
        training_provider:,
        accredited_provider:,
      )
    end
    let(:rollable_partnership2_two) do
      create(
        :provider_partnership,
        training_provider: provider_with_withdrawn_course,
        accredited_provider:,
      )
    end
    let(:not_rollable_partnership_one) do
      create(
        :provider_partnership,
        training_provider: provider_without_courses,
        accredited_provider:,
      )
    end
    let(:not_rollable_partnership2_two) do
      create(
        :provider_partnership,
        training_provider: create(:provider, recruitment_cycle: previous_target_cycle),
        accredited_provider:,
      )
    end

    before do
      given_we_have_providers_and_courses_on_previous_target_cycle
      rollable_partnership_one
      rollable_partnership2_two
      not_rollable_partnership_one
      not_rollable_partnership2_two
    end

    it "includes partnerships with eligible providers" do
      expect(rollover_progress.eligible_partnerships).to match_collection(
        [rollable_partnership_one, rollable_partnership2_two],
      )
    end

    it "returns correct count through delegation" do
      expect(rollover_progress.eligible_partnerships_count).to eq(2)
    end
  end

  describe "#rolled_over_partnerships" do
    let(:rolled_over_provider) { create(:provider, recruitment_cycle: target_cycle) }
    let(:new_provider) { create(:provider, :accredited_provider, recruitment_cycle: target_cycle) }

    let!(:valid_partnership) do
      create(:provider_partnership,
             training_provider: create(:provider, recruitment_cycle: target_cycle),
             accredited_provider: new_provider)
    end
    let!(:another_valid_partnership) do
      create(:provider_partnership,
             training_provider: rolled_over_provider,
             accredited_provider: new_provider)
    end
    let!(:old_cycle_partnership) do
      create(:provider_partnership,
             training_provider: create(:provider, recruitment_cycle: previous_target_cycle),
             accredited_provider: create(:provider, :accredited_provider, recruitment_cycle: previous_target_cycle))
    end

    it "includes partnerships with at least one rolled-over provider" do
      expect(rollover_progress.rolled_over_partnerships).to match_collection(
        [valid_partnership, another_valid_partnership],
        attribute_names: %w[id],
      )
    end

    it "returns correct count through delegation" do
      expect(rollover_progress.rolled_over_partnerships_count).to eq(2)
    end
  end

  describe "delegated count methods" do
    before do
      given_we_have_providers_and_courses_on_previous_target_cycle
      given_we_have_rolled_over_providers
      given_we_have_rolled_over_courses
    end

    it "delegates providers_without_published_courses_count" do
      expect(rollover_progress.providers_without_published_courses_count).to eq(2)
    end

    it "delegates eligible_providers_count" do
      expect(rollover_progress.eligible_providers_count).to eq(4)
    end

    it "delegates rolled_over_providers_count" do
      expect(rollover_progress.rolled_over_providers_count).to eq(1)
    end

    it "delegates rolled_over_courses_count" do
      expect(rollover_progress.rolled_over_courses_count).to eq(3)
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

    published_course
    accredited_course
    draft_course
    withdrawn_course
  end

  def given_we_have_rolled_over_providers
    rolled_over_provider
    new_provider
  end

  def given_we_have_rolled_over_courses
    rolled_over_published_course
    rolled_over_accredited_course
    rolled_over_withdrawn_course
  end
end
