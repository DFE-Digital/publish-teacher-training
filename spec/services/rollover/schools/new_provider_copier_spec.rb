# frozen_string_literal: true

require "rails_helper"

RSpec.describe Rollover::Schools::NewProviderCopier do
  subject(:copy_schools) { described_class.new.execute(provider:, new_provider:) }

  let(:provider) { create(:provider) }
  let(:new_provider) { create(:provider, recruitment_cycle: create(:recruitment_cycle, :next)) }
  let!(:provider_school) { create(:provider_school, provider:, site_code: "B") }
  let!(:main_site) { create(:provider_school, :main_site, provider:) }

  it "copies provider-school relationships with their GIAS school and site code" do
    expect { copy_schools }.to change(new_provider.schools, :count).from(0).to(2)

    expect(new_provider.schools.pluck(:gias_school_id, :site_code)).to contain_exactly(
      [provider_school.gias_school_id, "B"],
      [main_site.gias_school_id, Provider::School::MAIN_SITE_CODE],
    )
  end

  it "does not create legacy school sites" do
    expect { copy_schools }.not_to change(new_provider.sites, :count)
  end

  it "is idempotent" do
    2.times { copy_schools }

    expect(new_provider.schools.count).to eq(2)
  end
end
