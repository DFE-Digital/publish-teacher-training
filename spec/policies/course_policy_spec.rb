require "rails_helper"

describe CoursePolicy do
  let(:user) { create(:user) }
  subject { CoursePolicy.new(user, nil) }

  describe 'index?' do
    it 'allows the :index action for any authenticated user' do
      expect(subject.index?).to be_truthy
    end
  end

  describe 'show?' do
    let(:user) { create(:user) }
    let(:organisation) { create(:organisation, users: [user]) }
    let(:course) { create(:course) }
    let!(:provider) {
      create(:provider,
              course_count: 0,
              courses: [course],
              organisations: [organisation])
    }

    context 'when accessing a course of a provider that the user belongs provider' do
      subject { CoursePolicy.new(user, course) }

      it 'allows the :show action' do
        expect(subject.show?).to be_truthy
      end
    end

    context 'when accessing a course of a provider that the user does not have' do
      subject { CoursePolicy.new(create(:user), course) }

      it 'allows the :show action' do
        expect(subject.show?).to be_falsey
      end
    end
  end
end
