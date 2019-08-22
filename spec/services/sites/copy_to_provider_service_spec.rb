require 'rails_helper'

describe Sites::CopyToProviderService do
  describe '#copy_to_provider' do
    let(:site) { build :site }
    let(:provider) { create :provider, sites: [site] }
    let(:recruitment_cycle) { find_or_create :recruitment_cycle }
    let(:next_recruitment_cycle) { create :recruitment_cycle, :next }
    let(:next_provider) {
      create :provider,
             sites: [],
             provider_code: provider.provider_code,
             recruitment_cycle: next_recruitment_cycle
    }

    let(:service) { described_class.new }

    it 'makes a copy of the course in the new provider' do
      service.execute(site: site, new_provider: next_provider)

      next_site = next_provider.reload.sites.find_by(code: site.code)
      expect(next_site).not_to be_nil
    end

    it 'leaves the existing site alone' do
      service.execute(site: site, new_provider: next_provider)

      expect(provider.reload.sites).to eq [site]
    end

    context 'the site already exists in the new provider' do
      let!(:next_site) {
        create :site,
               code: site.code,
               provider: next_provider
      }

      it 'does not make a copy of the site' do
        # Something strange is going on with sites ... setting the code as we
        # do for next_site doesn't seem to work so we have to assign it here.
        next_site.update code: site.code

        expect { service.execute(site: site, new_provider: next_provider) }
          .not_to(change { next_provider.reload.sites.count })
      end
    end

    context 'the site is invalid' do
      before do
        provider
        site.update_columns address1: ''
        site.update_columns address3: ''
        site.update_columns postcode: ''
        site.update_columns location_name: ''
      end

      it 'makes a copy of the course in the new provider' do
        service.execute(site: site, new_provider: next_provider)

        next_site = next_provider.reload.sites.find_by(code: site.code)
        expect(next_site).not_to be_nil
      end
    end
  end
end
