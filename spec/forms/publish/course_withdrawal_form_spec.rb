# frozen_string_literal: true

require "rails_helper"

module Publish
  describe CourseWithdrawalForm, type: :model do
    let(:params) { {} }
    let(:course) { create(:course) }

    subject { described_class.new(course, params: params) }

    describe "validations" do
      before { subject.valid? }

      it "validates :confirm_course_code" do
        expect(subject.errors[:confirm_course_code]).to include(I18n.t("activemodel.errors.models.publish/course_withdrawal_form.attributes.confirm_course_code.invalid_code", course_code: course.course_code))
      end
    end

    describe "#save!" do
      let(:params) { { confirm_course_code: course.course_code } }

      it "withdraws the course" do
        expect(course).to receive(:withdraw)
        subject.save!
      end

      it "calls the course withdrawn notification service" do
        expect(NotificationService::CourseWithdrawn).to receive(:call).with(course: course)
        subject.save!
      end
    end
  end
end
