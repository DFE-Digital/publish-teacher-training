require "rails_helper"

describe CoursePolicy do
  let(:user) { create(:user) }

  subject { described_class }

  permissions :index?, :new? do
    it { is_expected.to permit(user, Course) }
  end

  permissions :show?, :update?, :withdraw?, :details? do
    let(:course) { create(:course) }
    let!(:provider) {
      create(:provider,
             courses: [course],
             users: [user])
    }

    it { is_expected.to permit(user, course) }

    context "with a user outside the provider" do
      let(:other_user) { create(:user) }

      it { is_expected.not_to permit(other_user, course) }
    end
  end

  describe "#permitted_attributes" do
    subject { described_class.new(user, build(:course)) }

    context "when non admin user" do
      it "returns user attributes" do
        expect(subject.permitted_attributes).to include(:english)
        expect(subject.permitted_attributes).not_to include(:name)
      end
    end

    context "when admin user" do
      let(:user) { build(:user, :admin) }

      it "returns user and admin attributes" do
        expect(subject.permitted_attributes).to include(:english)
        expect(subject.permitted_attributes).to include(:name)
      end
    end
  end

  describe CoursePolicy::Scope do
    let(:accredited_body) { create(:provider, :accredited_body, users: [user]) }
    let(:training_provider) { create(:provider) }
    let!(:course) { create(:course, provider: training_provider, accrediting_provider: accredited_body) }
    let!(:other_course) { create(:course) }

    subject { described_class.new(user, Course).resolve }

    context "user from the accredited_body" do
      it { is_expected.to contain_exactly(course) }
    end

    context "user not from the accredited body" do
      let(:accredited_body) { create(:provider, :accredited_body) }

      it { is_expected.to be_empty }
    end

    context "a user from the provider" do
      let(:user) { create(:user, providers: [training_provider]) }

      it { is_expected.to contain_exactly(course) }
    end

    context "an admin" do
      let(:user) { create(:user, :admin) }

      it { is_expected.to contain_exactly(course, other_course) }
    end
  end
end
