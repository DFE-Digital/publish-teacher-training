require 'mcb_helper'

describe '"mcb apiv1 providers find"' do
  let(:site1)     { build(:site) }
  let(:site2)     { build(:site) }
  let(:contact1)  { build(:contact, :utt_type) }
  let(:contact2)  { build(:contact, :admin_type) }
  let(:provider1) { create(:provider, sites: [site1], contacts: [contact1]) }
  let(:provider2) { create(:provider, sites: [site2], contacts: [contact2]) }

  it 'displays the info for the given provider' do
    url = "http://localhost:3001/api/v1/#{RecruitmentCycle.current_recruitment_cycle.year}/providers"
    next_url = url + '&' + {
        changed_since: provider2.created_at.utc.strftime('%FT%T.%16NZ'),
        per_page: 100
      }.to_query
    json = ActiveModel::Serializer::CollectionSerializer.new(
      [
        provider1,
        provider2
      ],
      serializer: ProviderSerializer
    )

    # For some reason provider1.sites.first.region_code_before_type_cast is
    # site to "london" here, in memory. In the DB, however, this value is
    # correct. This sounds likely related to how FactorBot does the build on an
    # object, but a reload here seems to fix it.
    provider1.sites.reload
    provider2.sites.reload

    stub_request(:get, url)
      .with(headers: {
              'Authorization' => 'Bearer bats'
            })
      .to_return(status: 200,
                 body: json.to_json,
                 headers: {
                   link: next_url + '; rel="next"'
                 })
    stub_request(:get, next_url)
      .to_return(status: 200,
                 body: [].to_json,
                 headers: {
                   link: next_url + '; rel="next"'
                 })

    output = with_stubbed_stdout do
      $mcb.run(%W[apiv1
                  providers
                  find
                  #{provider2.provider_code}])
    end

    expect(output).to have_text_table_row('institution_code',
                                          provider2.provider_code)
    expect(output).to(have_text_table_row(
                        site2.code,
                        site2.location_name,
                        '%02d' % site2.region_code_before_type_cast
                      ))
    expect(output).to(have_text_table_row(
                        'admin_contact',
                        contact2.name,
                        contact2.email,
                        contact2.telephone
                      ))
  end
end
