# frozen_string_literal: true

require "rails_helper"

describe RecruitmentCyclePolicy do
  subject { described_class }

  let(:current_recruitment_cycle) { find_or_create :recruitment_cycle }
  let(:next_recruitment_cycle) { find_or_create :recruitment_cycle, :next }

  describe "scope" do
    let(:user) { create(:user) }

    it "limits the providers to those the user is assigned to" do
      current_recruitment_cycle
      next_recruitment_cycle

      expect(Pundit.policy_scope(user, RecruitmentCycle.all))
        .to contain_exactly(current_recruitment_cycle, next_recruitment_cycle)
    end
  end

  permissions :index? do
    let(:user) { create(:user) }

    it { is_expected.to permit(user, RecruitmentCycle) }
  end

  # rubocop:disable RSpec/RepeatedExample
  permissions :show? do
    let(:user) { create(:user) }

    it { is_expected.to permit(user, current_recruitment_cycle) }
    it { is_expected.to permit(user, next_recruitment_cycle) }
  end

  permissions :edit? do
    let(:user) { create(:user) }

    it { is_expected.not_to permit(user, current_recruitment_cycle) }
    it { is_expected.to permit(user, next_recruitment_cycle) }
  end
  # rubocop:enable RSpec/RepeatedExample
end
