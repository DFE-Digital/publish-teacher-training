# == Schema Information
#
# Table name: organisation_user
#
#  id              :integer          not null, primary key
#  organisation_id :integer
#  user_id         :integer
#
# Indexes
#
#  IX_organisation_user_organisation_id                    (organisation_id)
#  IX_organisation_user_user_id                            (user_id)
#  index_organisation_user_on_organisation_id_and_user_id  (organisation_id,user_id) UNIQUE
#

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
