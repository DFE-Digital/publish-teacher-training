# == Schema Information
#
# Table name: access_request
#
#  id               :integer          not null, primary key
#  email_address    :text
#  first_name       :text
#  last_name        :text
#  organisation     :text
#  reason           :text
#  request_date_utc :datetime         not null
#  requester_id     :integer
#  status           :integer          not null
#  requester_email  :text
#

require 'rails_helper'

describe AccessRequest, type: :model do
  describe 'associations' do
    it { should belong_to(:requester) }
  end
  describe 'type' do
    it 'is an enum' do
      expect(subject)
        .to define_enum_for(:status)
              .backed_by_column_of_type(:integer)
              .with_values(
                requested: 0,
                approved: 1,
                completed: 2,
                declined: 3,
              )
    end
  end

  describe '#create_requested_user' do
    let(:organisation) { create(:organisation) }
    let(:access_request) { create(:access_request, requester_id: requesting_user.id) }
    let(:requesting_user) { create(:user, organisations: [organisation]) }

    context 'when requesting user has a single organisation' do
      subject do
        access_request.create_requested_user(access_request, requesting_user)
      end

      its(:email) { should eq access_request.email_address }
      its(:first_name) { should eq access_request.first_name }
      its(:last_name) { should eq access_request.last_name }
      its(:invite_date_utc) { should be_within(1.second).of Time.now.utc }
      its(:organisations) { should eq requesting_user.organisations }
    end

    context 'when requesting user has multiple organisations' do
      let(:second_organisation) { create(:organisation, name: 'second organisation') }
      let(:requesting_user) { create(:user, organisations: [organisation, second_organisation]) }

      subject do
        access_request.create_requested_user(access_request, requesting_user)
      end

      its(:email) { should eq access_request.email_address }
      its(:first_name) { should eq access_request.first_name }
      its(:last_name) { should eq access_request.last_name }
      its(:invite_date_utc) { should be_within(1.second).of Time.now.utc }
      its(:organisations) { should eq requesting_user.organisations }
    end
  end


  describe '#update_access' do
    context 'for a user with an email that does not exist' do
      let(:organisation) { create(:organisation) }
      let(:requesting_user) { create(:user, organisations: [organisation]) }
      let(:access_request) { create(:access_request, email_address: 'new_user.org.uk', requester_id: requesting_user.id) }

      context 'where requesting user has access to a single organisation' do
        before do
          access_request.update_access(access_request, requesting_user)
        end

        it 'it should create a user and give it permissions to all the requesting users orgs' do
          new_user = User.where(email: 'new_user.org.uk').first

          expect(new_user.organisations).to eq requesting_user.organisations
        end
      end

      context 'where requesting user has access to a multiple organisations' do
        let(:second_organisation) { create(:organisation, name: 'second organisation') }
        let(:requesting_user) { create(:user, organisations: [organisation, second_organisation]) }

        before do
          access_request.update_access(access_request, requesting_user)
        end

        it 'should create a user and give it permissions to all the requesting users orgs' do
          new_user = User.find_by!(email: 'new_user.org.uk')

          expect(new_user.organisations).to eq requesting_user.organisations
        end
          # :todo user that alredy exists
      end
    end
  end
end
