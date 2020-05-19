require "rails_helper"

describe CourseSubject, type: :model do
  describe "associations" do
    it { should belong_to(:course) }
  end

  describe "auditing" do
    it { should be_audited }
  end
end
