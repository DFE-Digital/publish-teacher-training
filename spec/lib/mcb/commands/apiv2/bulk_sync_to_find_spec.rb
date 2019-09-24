require "spec_helper"
require "mcb_helper"

describe "mcb apiv2 bulk_sync_to_find" do
  it "returns a plain-text JSON string" do
    sync_request = stub_request(:post, "http://localhost:3001/api/system/sync")
                     .with(headers: { "Authorization" => "Bearer Ge32" })

    with_stubbed_stdout do
      $mcb.run(%w[apiv2 bulk_sync_to_find])
    end

    expect(sync_request).to have_been_made
  end
end
