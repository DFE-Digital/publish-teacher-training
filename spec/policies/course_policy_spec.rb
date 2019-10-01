require "rails_helper"

describe CoursePolicy do
  let(:user) { create(:user) }

  subject { described_class }

  permissions :index?, :new? do
    it { should permit(user, Course) }
  end

  permissions :show?, :update?, :withdraw? do
    let(:organisation) { create(:organisation, users: [user]) }
    let(:course) { create(:course) }
    let!(:provider) {
      create(:provider,
             courses: [course],
             organisations: [organisation])
    }

    it { should permit(user, course) }

    context "with a user outside the organisation" do
      let(:other_user) { create(:user) }
      it { should_not permit(other_user, course) }
    end
  end
end
