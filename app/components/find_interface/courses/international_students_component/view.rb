module FindInterface
  module Courses
    class InternationalStudentsComponent::View < ViewComponent::Base
      def initialize(course:)
        super
        @course = course
      end

      def provider
        @provider ||= @course.provider
      end

      def right_required
        if @course.salaried?
          "right to work"
        else
          "right to study"
        end
      end

      def visa_sponsorship_status
        if !@course.salaried? && provider.can_sponsor_student_visa
          "<p class=\"govuk-body\">If you do not already have the right to study in the UK for the duration of this course, you may need to apply for a Student visa.</p>

          <p class=\"govuk-body\">To do this, you’ll need to be sponsored by your training provider.</p>

          <p class=\"govuk-body\">Before you apply for this course, contact us to check Student visa sponsorship is available. If it is, and you get a place on this course, we’ll help you apply for your visa.</p>".html_safe
        elsif @course.salaried? && provider.can_sponsor_skilled_worker_visa
          "<p class=\"govuk-body\">If you do not already have the right to work in the UK for the duration of this course, you may need to apply for a Skilled Worker visa.</p>

          <p class=\"govuk-body\">To do this, you’ll need to be sponsored by your employer.</p>

          <p class=\"govuk-body\">Before you apply for this course, contact us to check Skilled Worker visa sponsorship is available. If it is, and you get a place on this course, we’ll help you apply for your visa.</p>".html_safe
        elsif @course.salaried?
          "<p class=\"govuk-body\">If you do not already have the right to work in the UK, you may need to apply for a visa. The main visa for salaried courses is the Skilled Worker visa.</p>

          <p class=\"govuk-body\">To apply for a Skilled Worker visa you need to be sponsored by your employer.</p>

          <p class=\"govuk-body\">Sponsorship is not available for this course.</p>

          <p class=\"govuk-body\">If you need a visa, filter your course search to find courses with visa sponsorship.</p>".html_safe
        else
          "<p class=\"govuk-body\">If you do not already have the right to study in the UK, you may need to apply for a visa. The main visa for fee-paying courses (those that you have to pay for) is the Student visa.</p>

          <p class=\"govuk-body\">To apply for a Student visa, you’ll need to be sponsored by your training provider.</p>

          <p class=\"govuk-body\">Sponsorship is not available for this course.</p>

          <p class=\"govuk-body\">If you need a visa, filter your course search to find courses with visa sponsorship.</p>".html_safe
        end
      end
    end
  end
end
