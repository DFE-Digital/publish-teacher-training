require "rails_helper"

describe CoursePolicy do
  let(:user) { create(:user) }

  subject { described_class }

  permissions :index? do
    it 'allows the :index action for any authenticated user' do
      should permit(user)
    end
  end

  permissions :show?, :update? do
    let(:organisation) { create(:organisation, users: [user]) }
    let(:course) { create(:course) }
    let!(:provider) {
      create(:provider,
              course_count: 0,
              courses: [course],
              organisations: [organisation])
    }

    it 'permits when the user belongs to the organisation' do
      should permit(user, course)
    end

    context 'with a user outside the organisation' do
      let(:other_user) { create(:user) }
      it 'does not permit' do
        should_not permit(other_user, course)
      end
    end
  end
end
