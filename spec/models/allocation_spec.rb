require "rails_helper"

RSpec.describe Allocation do
  describe "validations" do
    before do
      subject.valid?
    end

    it "requires accredited_body" do
      expect(subject.errors["accredited_body"]).to include("can't be blank")
    end

    it "requires provider" do
      expect(subject.errors["provider"]).to include("can't be blank")
    end

    it "requires the accredited_body to be an accredited_body" do
      subject.accredited_body = create(:provider)
      subject.valid?
      expect(subject.errors["accredited_body"]).to include("must be an accredited body")
    end
  end
end
