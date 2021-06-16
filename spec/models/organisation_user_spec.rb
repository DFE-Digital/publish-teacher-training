require "rails_helper"

describe OrganisationUser, type: :model do
  subject { described_class.new }

  describe "associations" do
    it { is_expected.to belong_to(:organisation) }
    it { is_expected.to belong_to(:user) }
  end

  describe "auditing" do
    it { is_expected.to be_audited.associated_with(:organisation) }
  end
end
