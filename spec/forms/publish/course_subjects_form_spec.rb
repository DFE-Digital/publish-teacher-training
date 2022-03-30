# frozen_string_literal: true

require "rails_helper"

module Publish
  describe CourseSubjectsForm, type: :model do
    let(:params) { subject_ids }
    let(:subject_ids) { [biology_secondary_subject.id] }
    let(:name) { "History" }
    let(:course) { create(:course, :secondary, subjects: [history_secondary_subject], name: name) }
    let(:biology_secondary_subject) { find_or_create(:secondary_subject, :biology) }
    let(:history_secondary_subject) { find_or_create(:secondary_subject, :history) }

    subject { described_class.new(course, params: params) }

    describe "#save!" do
      let(:previous_site_names) { course.sites.map(&:location_name) }

      context "different subjects to course subjects" do
        let(:previous_subject_names) { course.subjects.map(&:subject_name) }
        let(:previous_course_name) { course.name }

        it "calls the course subjects updated notification service" do
          expect(NotificationService::CourseSubjectsUpdated).to receive(:call)
          .with(course: course, previous_subject_names: previous_subject_names, previous_course_name: previous_course_name)
          subject.save!
        end
      end

      context "same subects to course subects" do
        let(:params) { course.subject_ids }

        it "does not call the course subjects updated notification service" do
          expect(NotificationService::CourseSubjectsUpdated).not_to receive(:call)
          subject.save!
        end
      end
    end
  end
end
