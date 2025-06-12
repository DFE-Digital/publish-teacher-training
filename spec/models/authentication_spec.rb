require "rails_helper"

RSpec.describe Authentication, type: :model do
  let(:auth) { create(:authentication, :developer) }

  it "is associated with an authenticable" do
    expect(auth.authenticable).to be_a(Candidate)
  end

  it "authenticable is unique given provider" do
    candidate = create(:candidate, :logged_in)

    authentication = candidate.authentications.last.dup
    expect(authentication).not_to be_valid
    expect(authentication.errors.full_messages).to include("Authenticable should be unique to the given provider")
  end
end
