# frozen_string_literal: true

require 'rails_helper'

describe Support::SchoolForm, type: :model do
  subject { described_class.new(provider, location, params:) }

  let(:provider) { create(:provider) }
  let(:location) { provider.sites.build }
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

    context 'with missing location_name' do
      it 'is invalid' do
        params['location_name'] = ''
        expect(subject).not_to be_valid
        expect(subject.errors.messages).to eq({ location_name: ['Enter a location name'] })
      end
    end

    context 'with missing address1' do
      it 'is invalid' do
        params['address1'] = ''
        expect(subject).not_to be_valid
        expect(subject.errors.messages).to eq({ address1: ['Enter address line 1'] })
      end
    end

    context 'with missing address3' do
      it 'is invalid' do
        params['address3'] = ''
        expect(subject).not_to be_valid
        expect(subject.errors.messages).to eq({ address3: ['Enter a town or city'] })
      end
    end

    context 'with missing postcode' do
      it 'is invalid' do
        params['postcode'] = ''
        expect(subject).not_to be_valid
        expect(subject.errors.messages).to eq({ postcode: ['Enter a postcode', 'Postcode is not valid (for example, BN1 1AA)'] })
      end
    end

    context 'with invalid postcodes' do
      it 'is invalid' do
        params['postcode'] = 'tr1'
        expect(subject).not_to be_valid
        expect(subject.errors.messages).to eq({ postcode: ['Postcode is not valid (for example, BN1 1AA)'] })

        params['postcode'] = 'tr11'
        expect(subject).not_to be_valid
        expect(subject.errors.messages).to eq({ postcode: ['Postcode is not valid (for example, BN1 1AA)'] })

        params['postcode'] = 'tr11u'
        expect(subject).not_to be_valid
        expect(subject.errors.messages).to eq({ postcode: ['Postcode is not valid (for example, BN1 1AA)'] })
      end
    end

    context 'with valid postcode' do
      it 'is valid' do
        params['postcode'] = 'tr11un'
        expect(subject).to be_valid
      end
    end

    context 'with invalid urns' do
      it 'is invalid' do
        params['urn'] = '123'
        expect(subject).not_to be_valid
        expect(subject.errors.messages).to eq({ urn: ['Site URN must be 5 or 6 numbers'] })

        params['urn'] = 'qwert'
        expect(subject).not_to be_valid
        expect(subject.errors.messages).to eq({ urn: ['Site URN must be 5 or 6 numbers'] })
      end
    end

    context 'with valid urn' do
      it 'is valid' do
        params['urn'] = '12345'
        expect(subject).to be_valid
      end
    end

    context 'with existing provider.sites location_name' do
      let!(:location1) { create(:site, provider:, location_name: 'Hogwarts') }
      let(:params) do
        {
          location_name: location1.location_name,
          address1: 'My street',
          address3: 'My town',
          postcode: 'TR1 1UN'
        }
      end

      it 'is invalid' do
        expect(subject).not_to be_valid
        expect(subject.errors[:location_name]).to include('Name is in use by another location')
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
        expect(subject.errors.messages).to eq({ location_name: ['Enter a location name'] })
      end
    end
  end
end
