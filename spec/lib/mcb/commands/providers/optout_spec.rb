require 'spec_helper'
require 'mcb_helper'

describe 'mcb provider optin' do
  let(:provider) { create :provider, opted_in: true }

  let(:subject) do
    with_stubbed_stdout do
      $mcb.run(%W[provider optout #{provider.provider_code}])
    end
  end

  it 'sets the provider to be opted-out' do
    expect { subject }.to change {
      provider.reload.opted_in
    }.from(true)
     .to(false)
  end

  it 'updates the changed_at for the provider' do
    expect { subject } .to(
      change {
        provider.reload.changed_at
      }
    )
  end

  context 'provider with courses' do
    let(:course1) { build :course }
    let(:course2) { build :course }
    let(:provider) do
      create :provider,
             opted_in: true,
             courses: [course1, course2]
    end

    it 'updates the changed_at for all the provider courses' do
      expect { subject }.to(
        change {
          provider.reload.courses.pluck(:changed_at)
        }
      )
    end

    it 'does not set the created_at times to be exactly the same' do
      # Yes, this is testing the implementation of 'touch', but this is a
      # business requirement so it ensures we don't implement the same
      # mechanism wrongly.
      subject

      # These should be correct to the second, but not the nsec
      expect(course1.created_at.nsec).not_to eq course2.created_at.nsec
    end
  end
end
