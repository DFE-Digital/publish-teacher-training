require 'mcb_helper'

describe '"mcb providers touch"' do
  let(:provider) { create :provider, updated_at: 1.day.ago, changed_at: 1.day.ago }

  it 'updates the providers updated_at' do
    Timecop.freeze do
      with_stubbed_stdout do
        $mcb.run(%W[provider touch #{provider.provider_code}])
      end

      expect(provider.reload.updated_at).to eq Time.now
    end
  end

  it 'updates the providers changed_at' do
    Timecop.freeze do
      with_stubbed_stdout do
        $mcb.run(%W[provider touch #{provider.provider_code}])
      end

      expect(provider.reload.changed_at).to eq Time.now
    end
  end

  it 'adds audit comment' do
    expect {
      with_stubbed_stdout do
        $mcb.run(%W[provider touch #{provider.provider_code}])
      end
    }.to change { provider.reload.audits.count }
           .from(1).to(2)
  end
end
