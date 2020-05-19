require "rspec"

describe OrganisationUser, type: :model do
  subject { described_class.new }

  describe "associations" do
    it { should belong_to(:organisation) }
    it { should belong_to(:user) }
  end

  describe "auditing" do
    it { should be_audited.associated_with(:organisation) }
  end
end
