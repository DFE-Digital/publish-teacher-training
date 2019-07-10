# == Schema Information
#
# Table name: site
#
#  id            :integer          not null, primary key
#  address2      :text
#  address3      :text
#  address4      :text
#  code          :text             not null
#  location_name :text
#  postcode      :text
#  address1      :text
#  provider_id   :integer          default(0), not null
#  region_code   :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'rails_helper'

describe Site, type: :model do
  subject { create(:site) }

  describe 'auditing' do
    it { should be_audited.associated_with(:provider) }
  end

  it { is_expected.to validate_presence_of(:location_name) }
  it { is_expected.to validate_presence_of(:address1) }
  it { is_expected.to validate_presence_of(:postcode) }
  it { is_expected.to validate_uniqueness_of(:location_name).scoped_to(:provider_id) }
  it { is_expected.to validate_uniqueness_of(:code).case_insensitive.scoped_to(:provider_id) }
  it { is_expected.to validate_presence_of(:code) }
  it { is_expected.to validate_inclusion_of(:code).in_array(Site::POSSIBLE_CODES).with_message('must be A-Z, 0-9 or -') }

  describe 'associations' do
    it { should belong_to(:provider) }
  end

  describe '#touch_provider' do
    let(:site) { create(:site) }

    it 'sets changed_at to the current time' do
      Timecop.freeze do
        site.touch
        expect(site.provider.changed_at).to eq Time.now.utc
      end
    end

    it 'leaves updated_at unchanged' do
      timestamp = 1.hour.ago
      site.provider.update updated_at: timestamp
      site.touch
      expect(site.provider.updated_at).to eq timestamp
    end
  end

  describe 'after running validation' do
    let(:site) { build(:site, provider: provider) }
    let(:provider) { build(:provider) }
    subject { site }

    it 'is assigned a valid code by default' do
      expect { subject.valid? }.to change { subject.code.blank? }.from(true).to(false)
      expect(subject.errors[:code]).to be_empty
    end

    it 'is assigned easily-confused codes only when all others have been used up' do
      (Site::DESIRABLE_CODES - %w[A]).each { |code| create(:site, code: code, provider: provider) }
      subject.validate
      expect(subject.code).to eq('A')
    end
  end

  its(:recruitment_cycle) { should eq find(:recruitment_cycle) }

  describe "description" do
    subject { build(:site, location_name: 'Foo', code: '1') }
    its(:to_s) { should eq 'Foo (code: 1)' }
  end

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

    it 'makes a copy of the course in the new provider' do
      site.copy_to_provider(next_provider)

      next_site = next_provider.reload.sites.find_by(code: site.code)
      expect(next_site).not_to be_nil
    end

    it 'leaves the existing site alone' do
      site.copy_to_provider(next_provider)

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

        expect { site.copy_to_provider(next_provider) }
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
        site.copy_to_provider(next_provider)

        next_site = next_provider.reload.sites.find_by(code: site.code)
        expect(next_site).not_to be_nil
      end
    end
  end
end
