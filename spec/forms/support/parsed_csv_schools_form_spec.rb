# frozen_string_literal: true

require 'rails_helper'

module Support
  describe ParsedCSVSchoolsForm, type: :model do
    subject { described_class.new(provider, params:) }

    let(:provider) { create(:provider) }
    let(:params) { { school_details: build_list(:site, 3) } }

    describe 'validations' do
      before { subject.validate }

      context 'blank school_details' do
        let(:params) { { school_details: nil } }

        it 'is invalid' do
          expect(subject.errors[:school_details]).to include('Enter school details')
          expect(subject.valid?).to be(false)
        end
      end

      context 'valid params' do
        it 'is valid' do
          expect(subject.valid?).to be(true)
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
    end
  end
end
