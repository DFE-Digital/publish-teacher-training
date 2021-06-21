require "rails_helper"

describe AuthenticationService::DuplicateUserError do
  subject {
    described_class.new(
      "Disaster!",
      user_id: 1,
      user_sign_in_user_id: 2,
      existing_user_id: 3,
      existing_user_sign_in_user_id: 4,
    )
  }

  it "includes debug info in the message" do
    expect(subject.message).to eq <<~MESSAGE
      Disaster!
      user_id: 1,
      user_sign_in_user_id: 2,
      existing_user_id: 3,
      existing_user_sign_in_user_id: 4
    MESSAGE
  end
end
