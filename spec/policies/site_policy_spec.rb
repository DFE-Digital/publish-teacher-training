# frozen_string_literal: true

require 'rails_helper'

describe SitePolicy do
  subject { described_class }

  let(:user) { create(:user) }

  permissions :index? do
    it 'allows the :index action for any authenticated user' do
      expect(subject).to permit(user)
    end
  end

  permissions :show? do
    let(:site) { create(:site) }
    let!(:provider) do
      create(:provider,
             sites: [site],
             users: [user])
    end

    it { is_expected.to permit(user, site) }

    context 'with a user outside the provider' do
      let(:other_user) { create(:user) }

      it { is_expected.not_to permit(other_user, site) }
    end
  end
end
