require "spec_helper"
require "mcb_helper"

describe "mcb az apps config" do
  before :each do
    allow(MCB).to receive(:run_command)
                    .with('az webapp config appsettings list -g "aregrp" -n "dapp"')
                    .and_return(<<~EOCONFIG)
                      [
                        {
                          "name": "SETTING",
                          "value": "valoo"
                        }
                      ]
                    EOCONFIG
  end

  it "runs MCB::Azure.get_config" do
    result = with_stubbed_stdout do
      $mcb.run(%w[az apps config dapp aregrp])
    end
    result = result[:stdout]

    expect(result.chomp).to eq '{"SETTING"=>"valoo"}'
    expect(MCB).to have_received(:run_command)
  end
end
