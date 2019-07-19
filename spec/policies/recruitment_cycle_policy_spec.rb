require "rails_helper"

describe RecruitmentCyclePolicy do
  let(:current_recruitment_cycle) { find_or_create :recruitment_cycle }
  let(:next_recruitment_cycle) { find_or_create :recruitment_cycle, :next }

  describe 'scope' do
    let(:user) { create(:user) }

    it 'limits the providers to those the user is assigned to' do
      current_recruitment_cycle
      next_recruitment_cycle

      expect(Pundit.policy_scope(user, RecruitmentCycle.all))
        .to match_array [current_recruitment_cycle, next_recruitment_cycle]
    end
  end

  subject { described_class }

  permissions :index? do
    let(:user) { create(:user) }

    it { should permit(user, RecruitmentCycle) }
  end

  permissions :show? do
    let(:user) { create(:user) }

    it { should permit(user, current_recruitment_cycle) }
    it { should permit(user, next_recruitment_cycle) }
  end
end
