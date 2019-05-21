# == Schema Information
#
# Table name: user
#
#  id                     :integer          not null, primary key
#  email                  :text
#  first_name             :text
#  last_name              :text
#  first_login_date_utc   :datetime
#  last_login_date_utc    :datetime
#  sign_in_user_id        :text
#  welcome_email_date_utc :datetime
#  invite_date_utc        :datetime
#  accept_terms_date_utc  :datetime
#  state                  :string           not null
#

require 'rails_helper'

describe User, type: :model do
  subject { create(:user) }

  describe 'associations' do
    it { should have_and_belong_to_many(:organisations) }
    it { should have_many(:providers).through(:organisations) }
  end

  it { is_expected.to validate_presence_of(:email) }

  describe 'auditing' do
    it { should be_audited }
  end

  describe 'states' do
    context 'new user' do
      it { should be_new }
    end
  end

  describe 'state events' do
    before do
      subject.accept_transition_screen!
    end

    it { should be_transitioned }
  end

  describe '#admin?' do
    context 'user has an education.gov.uk email' do
      subject! { create(:user, email: 'test@education.gov.uk') }

      its(:admin?) { should be_truthy }

      it "doesn't show up in User.non_admins" do
        expect(User.non_admins).to be_empty
      end
    end

    context 'user has a digital.education.gov.uk email' do
      subject! { create(:user, email: 'test@digital.education.gov.uk') }

      its(:admin?) { should be_truthy }

      it "doesn't show up in User.non_admins" do
        expect(User.non_admins).to be_empty
      end
    end

    context 'user does not have a digital.education or education.gov.uk email' do
      subject { create(:user, email: 'test@hrmc.gov.uk') }

      its(:admin?) { should be_falsey }

      it "does shows up in User.non_admins" do
        expect(User.non_admins).to eq([subject])
      end
    end
  end

  describe '.active' do
    let!(:inactive_user) { create(:user, :inactive) }
    let!(:active_user) { create(:user, accept_terms_date_utc: Date.yesterday) }

    it "includes active users and excludes inactive users" do
      expect(User.active).to eq([active_user])
    end
  end
end
