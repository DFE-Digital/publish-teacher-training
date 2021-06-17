require "rails_helper"

describe AllocationCopyDataService do
  let!(:previous_cycle) { RecruitmentCycle.where(year: 2020).first || create(:recruitment_cycle, year: 2020) }
  let!(:current_cycle) { RecruitmentCycle.where(year: 2021).first || create(:recruitment_cycle, year: 2021) }

  let!(:provider1a) { create(:provider, :accredited_body, recruitment_cycle: previous_cycle) }
  let!(:provider1b) { create(:provider, :accredited_body, recruitment_cycle: current_cycle, provider_code: provider1a.provider_code) }

  let!(:provider2a) { create(:provider, recruitment_cycle: previous_cycle) }
  let!(:provider2b) { create(:provider, recruitment_cycle: current_cycle, provider_code: provider2a.provider_code) }

  let!(:allocation1) {
    create(:allocation,
           recruitment_cycle: previous_cycle, provider: provider1a, accredited_body: provider1a,
           number_of_places: 5, confirmed_number_of_places: 5)
  }
  let!(:allocation2) {
    create(:allocation,
           recruitment_cycle: previous_cycle, provider: provider2a, accredited_body: provider1a,
           number_of_places: 10, confirmed_number_of_places: 10)
  }

  it "copies over previous allocations to current allocation year" do
    expect(Provider.count).to be(4)
    expect(Allocation.count).to be(2)

    a1 = Allocation.where(provider_code: provider1a.provider_code).first
    expect(a1.provider.id).to eql(provider1a.id)
    expect(a1.accredited_body.id).to eql(provider1a.id)
    expect(a1.recruitment_cycle.id).to eql(previous_cycle.id)

    a2 = Allocation.where(provider_code: provider2a.provider_code).first
    expect(a2.provider.id).to eql(provider2a.id)
    expect(a2.accredited_body.id).to eql(provider1a.id)
    expect(a2.recruitment_cycle.id).to eql(previous_cycle.id)

    current_cycle = RecruitmentCycle.where(year: 2021).first!
    expect(current_cycle.previous.year).to eql("2020")

    AllocationCopyDataService.call(allocation_cycle_year: current_cycle.year)
    expect(Allocation.count).to be(4)
    expect(Allocation.where(recruitment_cycle_id: current_cycle.id).count).to be(2)

    b1 = Allocation.where(provider_code: provider1a.provider_code, recruitment_cycle_id: current_cycle.id).first
    expect(b1.provider_id).to eql(provider1b.id)
    expect(b1.accredited_body_id).to eql(provider1b.id)
    expect(b1.provider_code).to eql(provider1a.provider_code)
    expect(b1.accredited_body_code).to eql(provider1a.provider_code)
    expect(b1.number_of_places).to eql(allocation1.confirmed_number_of_places)
    expect(b1.confirmed_number_of_places).to be_nil

    b2 = Allocation.where(provider_code: provider2a.provider_code, recruitment_cycle_id: current_cycle.id).first
    expect(b2.provider_id).to eql(provider2b.id)
    expect(b2.accredited_body_id).to eql(provider1b.id)
    expect(b2.provider_code).to eql(provider2a.provider_code)
    expect(b2.accredited_body_code).to eql(provider1a.provider_code)
    expect(b2.number_of_places).to eql(allocation2.confirmed_number_of_places)
    expect(b2.confirmed_number_of_places).to be_nil
  end
end
