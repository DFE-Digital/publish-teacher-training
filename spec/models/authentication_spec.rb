require "rails_helper"

RSpec.describe Authentication, type: :model do
  let!(:auth) { create(:authentication) }

  it "is associated with an authenticable" do
    expect(auth.authenticable).to be_a(Candidate)
  end
end
