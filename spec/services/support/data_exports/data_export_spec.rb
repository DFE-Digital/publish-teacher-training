require "rails_helper"

RSpec.describe Support::DataExports::DataExport do
  subject { Support::DataExports::DataExport }

  describe "#all" do
    it "returns all export types" do
      expect(subject.all.count).to be(1)
      expect(subject.all.first.class).to eql(Support::DataExports::UsersExport)
    end
  end

  describe "#find" do
    it "finds users type" do
      type = subject.find("users")
      expect(type.class).to eql(Support::DataExports::UsersExport)
      expect(type.type).to eql("users")
    end
  end
end
