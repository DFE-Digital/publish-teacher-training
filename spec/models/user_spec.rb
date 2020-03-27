# == Schema Information
#
# Table name: user
#
#  accept_terms_date_utc  :datetime
#  admin                  :boolean          default(FALSE)
#  email                  :text
#  first_login_date_utc   :datetime
#  first_name             :text
#  id                     :integer          not null, primary key
#  invite_date_utc        :datetime
#  last_login_date_utc    :datetime
#  last_name              :text
#  sign_in_user_id        :text
#  state                  :string           not null
#  welcome_email_date_utc :datetime
#
# Indexes
#
#  IX_user_email  (email) UNIQUE
#

require "rails_helper"

describe User, type: :model do
  subject { create(:user, first_name: "Jane", last_name: "Smith", email: "jsmith@scitt.org") }

  describe "associations" do
    it { should have_many(:organisation_users) }
    it { should have_many(:organisations).through(:organisation_users) }
    it { should have_many(:providers).through(:organisations) }
    it { should have_many(:user_notifications) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:email).with_message("must contain @") }
    it { should_not allow_value("CAPS_IN_EMAIL@ACME.ORG").for(:email) }
    it { should_not allow_value("email_without_at").for(:email) }
    it { should_not allow_value(nil).for(:first_name) }
    it { should_not allow_value(nil).for(:last_name) }
    it { should_not allow_value("").for(:first_name) }
    it { should_not allow_value("").for(:last_name) }
    it { should_not allow_value("  ").for(:first_name) }
    it { should_not allow_value("  ").for(:last_name) }

    context "for an admin-user" do
      subject { create(:user, :admin) }
      it { should_not allow_value("general.public@example.org").for(:email) }
      it { should_not allow_value("some.provider@devon.gov.uk").for(:email) }
      it { should allow_value("bobs.your.uncle@digital.education.gov.uk").for(:email) }
      it { should allow_value("right.malarky@education.gov.uk").for(:email) }
    end
  end

  describe "auditing" do
    it { should be_audited }
  end

  describe "states" do
    context "new user" do
      it { should be_new }
    end
  end

  describe "transition state event" do
    before do
      subject.accept_transition_screen!
    end

    it { should be_transitioned }
  end

  describe "rollover state event" do
    before do
      subject.accept_transition_screen!
      subject.accept_rollover_screen!
    end

    it { should be_rolled_over }
  end

  describe "#to_s" do
    its(:to_s) { should eq("Jane Smith <jsmith@scitt.org>") }
  end

  describe "#admin?" do
    context "user is an admin" do
      subject! { create(:user, :admin) }

      its(:admin?) { should be_truthy }

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
        its(:admin?) { should be_falsey }

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
    let(:organisation) { create(:organisation) }
    let(:other_organisation) { create(:organisation) }
    let(:yet_other_organisation) { create(:organisation) }

    describe "one organisation" do
      before do
        subject.organisations = [organisation, other_organisation]
        subject.remove_access_to(organisation)
      end

      it "removes the right organisation"do
        expect(subject.reload.organisations).to eq([other_organisation])
      end
    end

    describe "multiple organisations" do
      before do
        subject.organisations = [organisation, other_organisation, yet_other_organisation]
        subject.remove_access_to [organisation, yet_other_organisation]
      end

      it "removes the right organisation"do
        expect(subject.reload.organisations).to eq([other_organisation])
      end
    end
  end
end
