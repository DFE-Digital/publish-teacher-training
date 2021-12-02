require "rails_helper"

describe User, type: :model do
  subject { create(:user, first_name: "Jane", last_name: "Smith", email: "jsmith@scitt.org") }

  describe "associations" do
    it { is_expected.to have_many(:providers).through(:user_permissions) }
    it { is_expected.to have_many(:user_notifications) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:email).with_message("must contain @") }
    it { is_expected.to validate_uniqueness_of(:email) }
    it { is_expected.to_not allow_value("CAPS_IN_EMAIL@ACME.ORG").for(:email) }
    it { is_expected.to_not allow_value("email_without_at").for(:email) }
    it { is_expected.to_not allow_value(nil).for(:first_name) }
    it { is_expected.to_not allow_value(nil).for(:last_name) }
    it { is_expected.to_not allow_value("").for(:first_name) }
    it { is_expected.to_not allow_value("").for(:last_name) }
    it { is_expected.to_not allow_value("  ").for(:first_name) }
    it { is_expected.to_not allow_value("  ").for(:last_name) }

    context "for an admin-user" do
      subject { create(:user, :admin) }

      it { is_expected.to_not allow_value("general.public@example.org").for(:email) }
      it { is_expected.to_not allow_value("some.provider@devon.gov.uk").for(:email) }
      it { is_expected.to allow_value("bobs.your.uncle@digital.education.gov.uk").for(:email) }
      it { is_expected.to allow_value("right.malarky@education.gov.uk").for(:email) }
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
