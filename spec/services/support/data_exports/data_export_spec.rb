require "rails_helper"

RSpec.describe Support::DataExports::DataExport do
  subject { Support::DataExports::DataExport }

  context "#all" do
    it "returns all export types" do
      expect(subject.all.count).to eql(1)
      expect(subject.all.first.class).to eql(Support::DataExports::UsersExport)
    end
  end

  context "#find" do
    it "finds users type" do
      type = subject.find("users")
      expect(type.class).to eql(Support::DataExports::UsersExport)
      expect(type.id).to eql("users")
    end
  end
end
