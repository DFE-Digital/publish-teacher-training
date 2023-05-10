# frozen_string_literal: true

require 'rails_helper'

describe ProviderPolicy do
  subject { described_class }

  let(:user) { build(:user) }
  let(:admin) { build(:user, :admin) }

  describe 'scope' do
    it 'limits the providers to those the user is assigned to' do
      provider1 = create(:provider, users: [user])
      _provider2 = create(:provider)

      expect(Pundit.policy_scope(user, Provider.all)).to eq [provider1]
    end
  end

  permissions :index?, :suggest?, :new? do
    it { is_expected.to permit user }
  end

  permissions :create? do
    let(:user_outside_org) { build(:user) }
    let(:provider) { build(:provider, users: [user]) }

    it { is_expected.not_to permit(user, provider) }
    it { is_expected.not_to permit(user_outside_org, provider) }
    it { is_expected.to permit(admin, provider) }
  end

  permissions :can_show_training_provider? do
    let(:accrediting_provider_enrichments) { [{ UcasProviderCode: course.accredited_provider_code }] }

    let(:allowed_user) { create(:user, providers: [provider]) }
    let(:not_allowed_user) { create(:user) }

    let(:course) { create(:course, :with_accrediting_provider) }

    let(:provider) { course.accrediting_provider }
    let(:training_provider) do
      course.provider
      course.provider.accrediting_provider_enrichments = accrediting_provider_enrichments
      course.provider
    end

    it { is_expected.to permit(admin, training_provider) }
    it { is_expected.to permit(allowed_user, training_provider) }
    it { is_expected.not_to permit(not_allowed_user, training_provider) }
  end

  describe '#permitted_provider_attributes' do
    context 'when user' do
      subject { described_class.new(user, build(:provider)) }

      it 'includes email' do
        expect(subject.permitted_provider_attributes).to include(:email)
      end

      it 'excludes provider_name' do
        expect(subject.permitted_provider_attributes).not_to include(:provider_name)
      end
    end

    context 'when admin' do
      subject { described_class.new(admin, build(:provider)) }

      it 'includes email' do
        expect(subject.permitted_provider_attributes).to include(:email)
      end

      it 'includes provider_name' do
        expect(subject.permitted_provider_attributes).to include(:provider_name)
      end
    end
  end
end
