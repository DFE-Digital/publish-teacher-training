require "rails_helper"

describe User, type: :model do
  subject { create(:user, first_name: "Jane", last_name: "Smith", email: "jsmith@scitt.org") }

  describe "associations" do
    it { is_expected.to have_many(:organisation_users) }
    it { is_expected.to have_many(:organisations).through(:organisation_users) }
    it { is_expected.to have_many(:providers).through(:user_permissions) }
    it { is_expected.to have_many(:user_notifications) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:email).with_message("must contain @") }
    it { is_expected.to validate_uniqueness_of(:email) }
    it { is_expected.not_to allow_value("CAPS_IN_EMAIL@ACME.ORG").for(:email) }
    it { is_expected.not_to allow_value("email_without_at").for(:email) }
    it { is_expected.not_to allow_value(nil).for(:first_name) }
    it { is_expected.not_to allow_value(nil).for(:last_name) }
    it { is_expected.not_to allow_value("").for(:first_name) }
    it { is_expected.not_to allow_value("").for(:last_name) }
    it { is_expected.not_to allow_value("  ").for(:first_name) }
    it { is_expected.not_to allow_value("  ").for(:last_name) }

    context "for an admin-user" do
      subject { create(:user, :admin) }

      it { is_expected.not_to allow_value("general.public@example.org").for(:email) }
      it { is_expected.not_to allow_value("some.provider@devon.gov.uk").for(:email) }
      it { is_expected.to allow_value("bobs.your.uncle@digital.education.gov.uk").for(:email) }
      it { is_expected.to allow_value("right.malarky@education.gov.uk").for(:email) }
    end
  end

  describe "#providers" do
    describe "#in_current_cycle" do
      let(:provider_in_current_cycle) { create(:provider) }
      let(:provider_in_previous_cycle) { create(:provider, :previous_recruitment_cycle) }

      before do
        subject.providers << provider_in_current_cycle
        subject.providers << provider_in_previous_cycle
      end

      it "returns the providers in the current cycle" do
        expect(subject.providers.in_current_cycle).to eq([provider_in_current_cycle])
      end
    end
  end

  describe "auditing" do
    it { is_expected.to be_audited }
  end

  describe "#to_s" do
    its(:to_s) { is_expected.to eq("Jane Smith <jsmith@scitt.org>") }
  end

  describe "#admin?" do
    context "user is an admin" do
      subject! { create(:user, :admin) }

      its(:admin?) { is_expected.to be_truthy }

      it "shows up in User.admins" do
        expect(User.admins).to eq([subject])
      end

      it "doesn't show up in User.non_admins" do
        expect(User.non_admins).to be_empty
      end
    end

    context "user is not an admin" do
      subject { create(:user) }

      context "when other domain" do
        its(:admin?) { is_expected.to be_falsey }

        it "is a non-admin user" do
          expect(User.non_admins).to eq([subject])
        end

        it "is not an admin" do
          expect(User.admins).to be_empty
        end
      end
    end
  end

  describe ".active" do
    let!(:inactive_user) { create(:user, :inactive) }
    let!(:active_user) { create(:user, accept_terms_date_utc: Date.yesterday) }

    it "includes active users and excludes inactive users" do
      expect(User.active).to eq([active_user])
    end
  end

  describe "#remove_access_to" do
    let(:provider) { create(:provider) }
    let(:other_provider) { create(:provider) }
    let(:yet_other_provider) { create(:provider) }

    describe "one provider" do
      before do
        subject.providers = [provider, other_provider]
        subject.remove_access_to(provider)
      end

      it "removes the right provider" do
        expect(subject.reload.providers).to eq([other_provider])
      end
    end

    describe "#associated_with_accredited_body?" do
      context "user is associated with accredited body" do
        let(:current_recruitment_cycle) { find_or_create(:recruitment_cycle) }
        let(:accredited_body) { create(:provider, :accredited_body, recruitment_cycle: current_recruitment_cycle) }

        subject { create(:user, providers: [accredited_body]) }

        it "returns true" do
          expect(subject.associated_with_accredited_body?).to be true
        end
      end

      context "user is not associated with an accredited body" do
        it "returns false" do
          expect(subject.associated_with_accredited_body?).to be false
        end
      end
    end

    describe "#notifications_configured?" do
      context "user has notifications configured" do
        before do
          subject.user_notifications << create(:user_notification)
        end

        it "returns true" do
          expect(subject.notifications_configured?).to be true
        end
      end

      context "user does not have notifications configured" do
        it "returns false" do
          expect(subject.notifications_configured?).to be false
        end
      end
    end

    describe "multiple providers" do
      before do
        subject.providers = [provider, other_provider, yet_other_provider]
        subject.remove_access_to [provider, yet_other_provider]
      end

      it "removes the right provider" do
        expect(subject.reload.providers).to eq([other_provider])
      end
    end
  end

  describe "#discard" do
    subject { create(:user) }

    context "before discarding" do
      its(:discarded?) { is_expected.to be false }

      it "is in kept" do
        expect(User.kept).to eq([subject])
      end

      it "is not in discarded" do
        expect(User.discarded).to be_empty
      end
    end

    context "after discarding" do
      before do
        subject.discard
      end

      its(:discarded?) { is_expected.to be true }

      it "is not in kept" do
        expect(User.kept).to be_empty
      end

      it "is in discarded" do
        expect(User.discarded).to eq([subject])
      end
    end
  end

  describe ".last_login_since" do
    context "30 days ago" do
      let!(:over_30_user) { create(:user, last_login_date_utc: 30.days.ago) }
      let!(:under_30_user) { create(:user, last_login_date_utc: 29.days.ago) }

      it "includes users logged in less than 30 days ago" do
        expect(described_class.last_login_since(30.days.ago)).to eq([under_30_user])
      end
    end
  end

  describe "notification subscribers" do
    let(:accredited_body) { create(:provider, :accredited_body) }
    let(:other_accredited_body) { create(:provider, :accredited_body) }
    let(:course) { create(:course, accredited_body_code: accredited_body.provider_code) }
    let(:subscribed_user) { create(:user) }
    let(:non_subscribed_user) { create(:user) }
    let(:user_subscribed_to_other_provider) { create(:user) }

    before do
      subscribed_notification
      non_subscribed_notification
      other_provider_notification
    end

    describe ".course_update_subscribers" do
      let(:subscribed_notification) do
        create(
          :user_notification,
          user: subscribed_user,
          course_update: true,
          provider_code: accredited_body.provider_code,
        )
      end

      let(:non_subscribed_notification) do
        create(
          :user_notification,
          user: non_subscribed_user,
          course_update: false,
          provider_code: accredited_body.provider_code,
        )
      end

      let(:other_provider_notification) do
        create(
          :user_notification,
          user: user_subscribed_to_other_provider,
          course_publish: true,
          provider_code: other_accredited_body.provider_code,
        )
      end

      it "returns users who are subscribed to course update notifications for a given accredited body" do
        expect(User.course_update_subscribers(course.accredited_body_code)).to eq([subscribed_user])
      end
    end

    describe ".course_publish_subscribers" do
      let(:subscribed_notification) do
        create(
          :user_notification,
          user: subscribed_user,
          course_publish: true,
          provider_code: accredited_body.provider_code,
        )
      end

      let(:non_subscribed_notification) do
        create(
          :user_notification,
          user: non_subscribed_user,
          course_publish: false,
          provider_code: accredited_body.provider_code,
        )
      end

      let(:other_provider_notification) do
        create(
          :user_notification,
          user: user_subscribed_to_other_provider,
          course_update: true,
          provider_code: other_accredited_body.provider_code,
        )
      end

      it "includes user who are subscribed to course publish notifications for a given accredited body" do
        expect(User.course_publish_subscribers(course.accredited_body_code)).to eq([subscribed_user])
      end
    end
  end
end
