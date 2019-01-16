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
#

require "rails_helper"

RSpec.describe SiteSerializer do
  let(:site) { create :site }

  subject { serialize(site) }

  it { is_expected.to include(name: site.location_name, campus_code: site.code) }
  it { is_expected.to include(region_code: site.region_code) }
end


RSpec.describe SiteSerializer do
  subject do
    serialize(site)["region_code"]
  end

  region_codes = 1..11

  region_codes.each do |region_code|
    describe "region code #{region_code} " do

      let(:site) { create :site, region_code: region_code }
      it { is_expected.to eql(format("%02d", region_code)) }
      it { expect(subject.length).to eql(2) }
    end
  end
end
