require "spec_helper"
require "mcb_helper"

describe "mcb api bulk_sync_to_find" do
  it "returns a plain-text JSON string" do
    sync_request = stub_request(:post, "http://localhost:3001/api/system/sync")
                     .with(headers: { "Authorization" => "Bearer Ge32" })

    with_stubbed_stdout do
      begin
        $mcb.run(%w[api bulk_sync_to_find])
      rescue SystemExit
        raise "SystemExit not allowed"
      end
    end

    expect(sync_request).to have_been_made
  end
end
