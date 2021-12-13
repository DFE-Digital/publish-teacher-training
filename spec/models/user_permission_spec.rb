require "rails_helper"

RSpec.describe UserPermission, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:provider) }
  end
end
