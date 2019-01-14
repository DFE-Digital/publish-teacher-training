require "rails_helper"

RSpec.describe SiteSerializer do
  let(:site) { create :site }
  subject { serialize(site) }

  it { is_expected.to include(name: site.location_name, campus_code: site.code, region_code: site.region_code) }
end
