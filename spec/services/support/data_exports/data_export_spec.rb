# frozen_string_literal: true

require "rails_helper"

RSpec.describe Support::DataExports::DataExport do
  subject { described_class }

  describe "#all" do
    it "returns all export types" do
      expect(subject.all.count).to be(2)
      export_types = subject.all.map(&:class)

      expect(export_types).to include(Support::DataExports::UsersExport)
      expect(export_types).to include(Support::DataExports::FeedbackExport)
    end
  end

  describe "#find" do
    it "finds users type" do
      type = subject.find("users")
      expect(type.class).to eql(Support::DataExports::UsersExport)
      expect(type.type).to eql("users")
    end

    it "finds feedback type" do
      type = subject.find("feedback")
      expect(type.class).to eql(Support::DataExports::FeedbackExport)
      expect(type.type).to eql("feedback")
    end
  end
end
