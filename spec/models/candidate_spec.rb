require "rails_helper"

RSpec.describe Candidate, type: :model do
  describe "validates email_address" do
    it "validates email_address" do
      candidate = build(:candidate, email_address: "bademail")
      candidate.validate

      expect(candidate.errors.full_messages).to include("Email address Enter an email address in the correct format, like name@example.com")
    end

    it "normalizes the users email address" do
      email_address = "  withpaddingANDuppercase@email.com"
      candidate = build(:candidate, email_address:)
      candidate.save

      expect(candidate.reload.email_address).to eq("withpaddinganduppercase@email.com")
    end
  end

  describe "associations" do
    it { is_expected.to have_many(:saved_courses).dependent(:destroy) }
    it { is_expected.to have_many(:saved_course_records).through(:saved_courses).source(:course) }

    it "can have many saved courses through saved_course_records" do
      candidate = create(:candidate)

      course1 = create(:course)
      course2 = create(:course)

      create(:saved_course, candidate:, course: course1)
      create(:saved_course, candidate:, course: course2)

      expect(candidate.saved_courses.count).to eq(2)
      expect(candidate.saved_course_records).to contain_exactly(course1, course2)
    end

    it "destroys associated saved_courses when the candidate is destroyed" do
      candidate = create(:candidate)
      course = create(:course)

      create(:saved_course, candidate:, course:)

      expect {
        candidate.destroy
      }.to change(SavedCourse, :count).by(-1)
    end
  end

  describe "logged in" do
    it "has a session and authentication" do
      candidate = build(:candidate, :logged_in)
      expect(candidate.sessions.first).to be_a(Session)
      expect(candidate.authentications.first).to be_a(Authentication)
    end
  end

  describe ".search" do
    it "returns all candidates when query is blank" do
      candidate_one = create(:candidate, email_address: "alpha@example.com")
      candidate_two = create(:candidate, email_address: "beta@example.com")

      expect(described_class.search(nil)).to contain_exactly(candidate_one, candidate_two)
      expect(described_class.search("")).to contain_exactly(candidate_one, candidate_two)
      expect(described_class.search("   ")).to contain_exactly(candidate_one, candidate_two)
    end

    it "performs a case-insensitive partial match on email_address" do
      match_1 = create(:candidate, email_address: "user.one@example.com")
      match_2 = create(:candidate, email_address: "two+one@example.org")
      _other = create(:candidate, email_address: "random@elsewhere.net")

      results = described_class.search("ONE")
      expect(results).to contain_exactly(match_1, match_2)
    end

    it "escapes SQL LIKE wildcards so they are treated literally" do
      percent = create(:candidate, email_address: "percent%user@example.com")
      under = create(:candidate, email_address: "under_score@example.com")
      plain = create(:candidate, email_address: "plain@example.com")

      expect(described_class.search("percent%user")).to contain_exactly(percent)
      expect(described_class.search("under_score")).to contain_exactly(under)
      expect(described_class.search("plain")).to contain_exactly(plain)
    end
  end
end
