# frozen_string_literal: true

require 'rails_helper'

module Support
  describe CopyCoursesForm, type: :model do
    subject { described_class.new(target_provider, provider) }

    let(:provider) { create(:provider) }

    describe 'validations' do
      let(:target_provider) { provider }

      context 'unique provider' do
        it 'is not valid' do
          expect(subject).not_to be_valid
          expect(subject.errors.messages[:provider]).to include('Choose different providers')
        end
      end

      context 'provider must be present' do
        let(:target_provider) { nil }

        it 'is not valid' do
          expect(subject).not_to be_valid
          expect(subject.errors.messages[:target_provider]).to include("Provider can't be blank")
        end
      end
    end
  end
end
