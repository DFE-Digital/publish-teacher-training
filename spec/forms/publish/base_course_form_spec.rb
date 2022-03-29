# frozen_string_literal: true

require "rails_helper"

module Publish
  class InheritedBaseCourseForm < BaseCourseForm
    def compute_fields
      {}
    end
  end

  describe "BaseCourseForm", type: :model do
    let(:params) { {} }
    let(:course) { create(:course) }

    let(:form) { InheritedBaseCourseForm.new(course, params: params) }

    subject { form }

    describe "#save!" do
      it "calls the course updated notification service" do
        expect(NotificationService::CourseUpdated).to receive(:call).with(course: course)
        subject.save!
      end
    end
  end
end
