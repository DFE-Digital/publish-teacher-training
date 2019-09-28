require "mcb_helper"

describe '"mcb apiv1 providers list"' do
  let(:current_cycle) { find_or_create(:recruitment_cycle) }
  let(:next_cycle) { find_or_create(:recruitment_cycle, :next) }
  let(:provider1) { create(:provider, recruitment_cycle: current_cycle) }
  let(:provider2) { create(:provider, recruitment_cycle: next_cycle) }

  it "lists providers for the default recruitment year" do
    url = "http://localhost:3001/api/v1/#{RecruitmentCycle.current_recruitment_cycle.year}/providers"
    next_url = url + "&" + {
        changed_since: provider2.created_at.utc.strftime("%FT%T.%6NZ"),
        per_page: 100,
      }.to_query
    json = ActiveModel::Serializer::CollectionSerializer.new(
      [
        provider1,
        provider2,
      ],
      serializer: ProviderSerializer,
    )

    stub_request(:get, url)
      .with(headers: {
              "Authorization" => "Bearer bats",
            })
      .to_return(status: 200,
                 body: json.to_json,
                 headers: {
                   link: next_url + '; rel="next"',
                 })
    stub_request(:get, next_url)
      .to_return(status: 200,
                 body: [].to_json,
                 headers: {
                   link: next_url + '; rel="next"',
                 })

    output = with_stubbed_stdout do
      $mcb.run(%W[apiv1
                  providers
                  list])
    end
    output = output[:stdout]

    expect(output).to have_text_table_row("Code",
                                          "Name")
    expect(output).to have_text_table_row(provider1.provider_code, provider1.provider_name)
    expect(output).to have_text_table_row(provider2.provider_code, provider2.provider_name)
  end

  it "lists providers for a given recruitment year" do
    url = "http://localhost:3001/api/v1/#{next_cycle.year}/providers"
    next_url = url + "&" + {
        changed_since: provider2.created_at.utc.strftime("%FT%T.%6NZ"),
        per_page: 100,
      }.to_query
    json = ActiveModel::Serializer::CollectionSerializer.new(
      [
        provider2,
      ],
      serializer: ProviderSerializer,
    )

    stub_request(:get, url)
      .with(headers: {
              "Authorization" => "Bearer bats",
            })
      .to_return(status: 200,
                 body: json.to_json,
                 headers: {
                   link: next_url + '; rel="next"',
                 })
    stub_request(:get, next_url)
      .to_return(status: 200,
                 body: [].to_json,
                 headers: {
                   link: next_url + '; rel="next"',
                 })

    output = with_stubbed_stdout do
      $mcb.run(%W[apiv1
                  providers
                  list -r #{next_cycle.year}])
    end
    output = output[:stdout]

    expect(output).to have_text_table_row("Code",
                                          "Name")
    expect(output).to have_text_table_row(provider2.provider_code, provider2.provider_name)
    expect(output).not_to have_text_table_row(provider1.provider_code, provider1.provider_name)
  end
end
