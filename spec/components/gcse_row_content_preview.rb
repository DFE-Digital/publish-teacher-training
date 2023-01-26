# frozen_string_literal: true

class GcseRowContentPreview < ViewComponent::Preview
  def incomplete
    course = Course.new(course_code: 'C0D3', provider: Provider.new(provider_code: 'E2E', recruitment_cycle: RecruitmentCycle.new(year: Settings.current_recruitment_cycle_year)))

    render(GcseRowContent.new(course: course.decorate))
  end

  def complete_fulfilled_fields
    course = Course.new(
      accept_pending_gcse: true,
      accept_gcse_equivalency: true,
      accept_english_gcse_equivalency: true,
      accept_maths_gcse_equivalency: true,
      accept_science_gcse_equivalency: true,
      additional_gcse_equivalencies: 'Geography'
    )

    render(GcseRowContent.new(course: course.decorate))
  end

  def complete_unfulfilled_fields
    course = Course.new(
      accept_pending_gcse: false,
      accept_gcse_equivalency: false,
      accept_english_gcse_equivalency: false,
      accept_maths_gcse_equivalency: false,
      accept_science_gcse_equivalency: false,
      additional_gcse_equivalencies: nil
    )

    render(GcseRowContent.new(course: course.decorate))
  end
end
