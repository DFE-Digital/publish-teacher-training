# frozen_string_literal: true

require "rails_helper"

module Publish
  describe CourseStudyModeForm, type: :model do
    let(:course) { create(:course) }

    subject { described_class.new(course, params:) }

    context "when params are blank" do
      let(:params) { {} }

      describe "#save!" do
        it "does not call the course.ensure_site_statuses_match_study_mode" do
          expect(course).to receive(:changed?)
          expect(course).not_to receive(:ensure_site_statuses_match_study_mode)
          subject.save!
        end
      end
    end

    context "when params are study mode is part_time" do
      let(:params) { { study_mode: "part_time" } }

      describe "#save!" do
        it "does calls the course.ensure_site_statuses_match_study_mode" do
          expect(course).to receive(:changed?)
          expect(course).not_to receive(:ensure_site_statuses_match_study_mode)
          subject.save!
        end
      end
    end
  end
end
