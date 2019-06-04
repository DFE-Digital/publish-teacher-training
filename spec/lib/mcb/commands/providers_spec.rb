require 'spec_helper'
require 'mcb_helper'

describe 'mcb providers' do
  it 'configures the database', mcb_cli: true do
    allow(MCB).to receive(:init_rails)

    with_stubbed_stdout do
      $mcb.run(%w[providers --webapp=banana])
    end

    expect(MCB).to have_received(:init_rails).with(hash_including(webapp: 'banana'))
  end
end
