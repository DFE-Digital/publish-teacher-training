# frozen_string_literal: true

require 'rails_helper'

describe Support::LocationForm, type: :model do
  subject { described_class.new(provider, location, params:) }

  let(:provider) { create(:provider) }
  let(:location) { create(:site) }
  let(:params) do
    {
      location_name: 'The location',
      address1: 'My street',
      address3: 'My town',
      postcode: 'TR1 1UN'
    }
  end

  describe 'validations' do
    it { is_expected.to be_valid }

    it { is_expected.to validate_presence_of(:location_name).with_message('Enter a name') }
    it { is_expected.to validate_presence_of(:address1).with_message('Enter address line 1') }
    it { is_expected.to validate_presence_of(:address3).with_message('Enter a town or city') }
    it { is_expected.to validate_presence_of(:postcode).with_message('Enter a postcode') }

    it { is_expected.not_to allow_values('tr', 'tr11', 'tr11u').for(:postcode).with_message('Enter a real postcode') }
    it { is_expected.to allow_value('tr11un').for(:postcode) }

    it { is_expected.not_to allow_values('12', '123', '1234', 'qwert').for(:urn).with_message('Site URN must be 5 or 6 numbers') }

    context 'with existing Site name' do
      let(:params) do
        {
          location_name: location.location_name,
          address1: 'My street',
          address3: 'My town',
          postcode: 'TR1 1UN'
        }
      end

      it 'is invalid' do
        expect(subject).not_to be_valid
        expect(subject.errors[:location_name]).to include('Name is taken')
      end
    end
  end

  describe 'save!' do
    context 'valid form' do
      it 'updates the provider location with the new details' do
        expect { subject.save! }
          .to change(location, :location_name).to('The location')
          .and change(location, :address1).to('My street')
          .and change(location, :address3).to('My town')
          .and change(location, :postcode).to('TR1 1UN')
      end
    end

    context 'invalid form' do
      let(:params) { { postcode: 'tr1', location_name: 'Another site', address1: 'Another street' } }

      it 'does not update the provider location with invalid details' do
        expect { subject.save! }.not_to(change(location, :postcode))
        expect { subject.save! }.not_to(change(location, :location_name))
        expect { subject.save! }.not_to(change(location, :address1))
        expect { subject.save! }.not_to(change(location, :address3))
      end
    end
  end

  describe '#stash' do
    context 'valid details' do
      it 'returns true' do
        expect(subject.stash).to be true
        expect(subject.errors.messages).to be_blank
      end
    end

    context 'missing required attribute' do
      let(:params) do
        {
          location_name: '',
          address1: 'My street',
          address3: 'My town',
          postcode: 'TR1 1UN'
        }
      end

      it 'returns nil' do
        expect(subject.stash).to be_nil
        expect(subject.errors.messages).to eq({ location_name: ['Enter a name'] })
      end
    end
  end
end
