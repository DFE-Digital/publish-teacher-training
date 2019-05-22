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

  describe 'auditing' do
    it { should be_audited }
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

  describe '#approve' do
    let(:access_request) { build(:access_request) }

    subject { access_request.approve }

    it 'marks the access request as completed' do
      expect { subject }.to change { access_request.status }
        .from('requested')
        .to('completed')
    end
  end

  describe '#index' do
    context 'with all types of access requests' do
      let!(:access_request1) { create(:access_request, :requested) }
      let!(:access_request2) { create(:access_request, :requested) }
      let!(:access_request3) { create(:access_request, :declined) }
      let!(:access_request4) { create(:access_request, :approved) }
      let!(:access_request5) { create(:access_request, :completed) }

      subject { AccessRequest.requested }

      it { should include access_request1, access_request2 }
      it { should_not include access_request3, access_request4, access_request5 }
    end
  end

  describe '#by_request_date' do
    let!(:access_request1) { create(:access_request, request_date_utc: Time.now.utc) }
    let!(:access_request2) { create(:access_request, request_date_utc: 2.minutes.ago.utc) }

    it 'returns the new enrichment first' do
      expect(AccessRequest.by_request_date.first).to eq access_request2
      expect(AccessRequest.by_request_date.last).to eq access_request1
    end
  end
end
