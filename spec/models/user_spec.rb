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

  describe '#opted_in?' do
    context 'user is opted in' do
      subject { create(:user, :opted_in) }

      its(:opted_in?) { should be_truthy }
    end

    context 'user is not opted in' do
      subject { create(:user) }

      its(:opted_in?) { should be_falsey }
    end
  end
end
