require 'spec_helper'
require 'mcb_helper'

describe 'mcb az apps list' do
  before :each do
    allow(MCB).to receive(:run_command)
                    .with('az webapp list')
                    .and_return(<<~EOAPPS)
                      [
                        {
                          "name": "dapp",
                          "resourceGroup": "aregrp"
                        }
                      ]
                    EOAPPS
  end

  it 'returns the listing of apps' do
    result = with_stubbed_stdout do
      $mcb.run(%w[az apps list])
    end
    result = result[:stdout]

    expect(result).to match %r{^dapp \| aregrp\s+$}
  end
end
