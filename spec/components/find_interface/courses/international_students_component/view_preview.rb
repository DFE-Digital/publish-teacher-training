# frozen_string_literal: true

module FindInterface::Courses::InternationalStudentsComponent
  class ViewPreview < ViewComponent::Preview
    def salaried_course
      course = Course.new(course_code: "FIND", program_type: "school_direct_salaried_training_programme",
        provider:).decorate
      render FindInterface::Courses::InternationalStudentsComponent::View.new(course:)
    end

    def fee_paying_course
      course = Course.new(course_code: "FIND", program_type: "school_direct_training_programme",
        provider:).decorate
      render FindInterface::Courses::InternationalStudentsComponent::View.new(course:)
    end

    def non_salaried_course_and_can_sponsor_student_visa
      course = Course.new(course_code: "FIND", program_type: "school_direct_training_programme", can_sponsor_student_visa: true,
        provider:).decorate
      render FindInterface::Courses::InternationalStudentsComponent::View.new(course:)
    end

    def salaried_course_and_can_sponsor_skilled_worker_visa
      course = Course.new(course_code: "FIND", program_type: "school_direct_salaried_training_programme",
        can_sponsor_skilled_worker_visa: true,
        provider:).decorate
      render FindInterface::Courses::InternationalStudentsComponent::View.new(course:)
    end

  private

    def provider
      @provider ||= Provider.new(provider_code: "DFE")
    end
  end
end
