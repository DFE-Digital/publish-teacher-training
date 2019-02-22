require "rails_helper"

describe CoursePolicy do
  let(:user) { create(:user) }
  subject { CoursePolicy.new(user, nil) }

  describe 'index?' do
    it 'allows the :index action for any authenticated user' do
      expect(subject.index?).to be_truthy
    end
  end
end
