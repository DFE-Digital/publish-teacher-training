require "rails_helper"

describe CoursePolicy do
  let(:user) { create(:user) }
  let(:organisation) { create(:organisation, users: [user]) }

  subject { described_class }

  permissions :index?, :new? do
    it { should permit(user, Course) }
  end

  permissions :show?, :update?, :withdraw? do
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

  describe CoursePolicy::Scope do
    let(:accredited_body) { create(:provider, :accredited_body, organisations: [organisation]) }
    let(:training_provider) { create(:provider) }
    let!(:course) { create(:course, provider: training_provider, accrediting_provider: accredited_body) }
    let!(:other_course) { create(:course) }

    subject { described_class.new(user, Course).resolve }

    before { organisation }

    context "user from the accredited_body" do
      it { is_expected.to contain_exactly(course) }
    end

    context "user not from the accredited body" do
      let(:organisation) { create(:organisation) }

      it { is_expected.to be_empty }
    end

    context "a user from the provider" do
      let(:organisation) { training_provider.organisations.first }
      let(:user) { create(:user, organisations: [organisation]) }

      it { is_expected.to contain_exactly(course) }
    end

    context "an admin" do
      let(:user) { create(:user, :admin) }
      it { is_expected.to contain_exactly(course, other_course) }
    end
  end
end
