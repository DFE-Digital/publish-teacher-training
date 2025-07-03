# frozen_string_literal: true

require "rails_helper"

module Find
  describe CandidateAuthenticator do
    let(:oauth) do
      CandidateAuthHelper.mock_auth
    end

    subject { described_class.new(oauth:) }

    describe ".call" do
      context "when no candidate exists yet" do
        it "creates a new Candidate and Authentication" do
          expect { subject.call }.to change(Candidate, :count).by(1).and(change(::Authentication, :count).by(1))
        end
      end

      context "when candidate already exists" do
        before { create(:find_developer_candidate) }

        it "creates a new Candidate and Authentication" do
          expect { subject.call }.to not_change(Candidate, :count).and(not_change(::Authentication, :count))
        end
      end

      context "when candidate email changes" do
        let(:oauth) do
          CandidateAuthHelper.mock_auth(email_address: "different@example.com")
        end

        let!(:candidate) { create(:find_developer_candidate) }

        it "updates the existing Candidate email address" do
          expect { subject.call }.to change { candidate.reload.email_address }.to("different@example.com")
        end
      end
    end
  end
end
