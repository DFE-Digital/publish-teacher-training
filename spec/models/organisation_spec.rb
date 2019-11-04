# == Schema Information
#
# Table name: organisation
#
#  id     :integer          not null, primary key
#  name   :text
#  org_id :text
#
# Indexes
#
#  IX_organisation_org_id  (org_id) UNIQUE
#

require "rails_helper"

describe Organisation, type: :model do
  subject { create(:organisation) }

  describe "associations" do
    it { should have_many(:organisation_users) }
    it { should have_many(:users).through(:organisation_users) }
    it { should have_and_belong_to_many(:providers) }
  end

  describe "validations" do
    subject { build(:organisation, name: name) }

    context "when name is empty string" do
      let(:name) { "  " }

      it { should_not be_valid }
    end

    context "when name is nil" do
      let(:name) { nil }

      it { should_not be_valid }
    end

    context "when name is a school" do
      let(:name) { "High School" }

      it { should be_valid }
    end
  end

  describe "auditing" do
    it { should be_audited }
    it { should have_associated_audits }

    it "a destroyed user" do
      user = create(:user)
      user.save!
      organisation = create(:organisation)
      organisation.add_user(user)
      user.remove_access_to(organisation)
      organisation.reload
      expect(organisation.associated_audits.last.action).to eq("destroy")
    end
  end

  describe "#add_user" do
    let(:user) { create(:user) }
    it "adds a user" do
      subject.add_user(user)
      expect(subject.users).to contain_exactly(user)
    end
  end
end
