# frozen_string_literal: true

require "rails_helper"

describe GenerateAndSendMagicLinkService do
  let(:user) { create(:user) }
  let(:uuid) { "not-a-random-uuid" }

  it "creates and saves magic link token for the user" do
    allow(SecureRandom).to receive(:uuid).and_return(uuid)

    described_class.call(user:)

    expect(user.magic_link_token).to eq uuid
    expect(user.magic_link_token_sent_at).to be_within(4.seconds).of(Time.zone.now)
  end

  it "sends the magic link email" do
    expect {
      described_class.call(user:)
    }.to(
      have_enqueued_email(MagicLinkEmailMailer, :magic_link_email)
        .with { user.reload } # Use block to reload user after queue processing
        .on_queue(:mailers),
    )
  end
end
