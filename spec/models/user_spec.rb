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
#  aasm_state             :string
#

require 'rails_helper'

RSpec.describe User, type: :model do
  subject { create(:user) }

  describe 'associations' do
    it { should have_and_belong_to_many(:organisations) }
    it { should have_many(:providers).through(:organisations) }
  end

  it { is_expected.to validate_presence_of(:email) }

  describe 'auditing' do
    it { should be_audited }
  end
end
