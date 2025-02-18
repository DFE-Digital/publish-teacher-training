# frozen_string_literal: true

module ViewHelper
  def govuk_back_link_to(url = :back, body = 'Back')
    render GovukComponent::BackLinkComponent.new(
      text: body,
      href: url,
      classes: 'govuk-!-display-none-print',
      html_attributes: {
        data: {
          qa: 'page-back'
        }
      }
    )
  end

  def x_find_url(relative_path)
    URI.join(Settings.find_url, relative_path).to_s
  end

  def x_find_course_page_url(provider_code:, course_code:)
    x_find_url(find_course_path(provider_code, course_code))
  end

  def bat_contact_email_address
    Settings.support_email
  end

  def bat_contact_email_address_with_wrap
    # https://developer.mozilla.org/en-US/docs/Web/HTML/Element/wbr
    # The <wbr> element will not be copied when copying and pasting the email address
    bat_contact_email_address.gsub('@', '<wbr>@').html_safe
  end

  def bat_contact_mail_to(name = nil, **)
    govuk_mail_to(bat_contact_email_address, name || bat_contact_email_address_with_wrap, **)
  end

  # def feedback_link_to
  #  t("feedback.link")
  # end

  def title_with_error_prefix(title, error)
    "#{t('page_titles.error_prefix') if error}#{title}"
  end

  def enrichment_error_url(provider_code:, course:, field:, message: nil)
    base = "/publish/organisations/#{provider_code}/#{course.recruitment_cycle_year}/courses/#{course.course_code}"
    provider_base = "/publish/organisations/#{provider_code}/#{course.recruitment_cycle_year}"
    accrediting_provider = Settings.features.provider_partnerships ? ratifying_provider_publish_provider_recruitment_cycle_course_path(course.provider_code, course.recruitment_cycle_year, course.course_code) : accredited_provider_publish_provider_recruitment_cycle_course_path(course.provider_code, course.recruitment_cycle_year, course.course_code)

    if field.to_sym == :base
      base_errors_hash(provider_code, course)[message]
    else
      {
        about_course: "#{base}/about-this-course?display_errors=true#publish-course-information-form-about-course-field-error",
        how_school_placements_work: "#{base}/school-placements?display_errors=true#publish-course-information-form-how-school-placements-work-field-error",
        fee_uk_eu: "#{base}/fees?display_errors=true#fee_uk_eu-error",
        fee_international: "#{base}/fees?display_errors=true#fee_internation-error",
        course_length: "#{base}/length?display_errors=true#course_length-error",
        salary_details: "#{base}/salary?display_errors=true#salary_details-error",
        required_qualifications: "#{base}/requirements?display_errors=true#required_qualifications_wrapper",
        age_range_in_years: "#{base}/age-range?display_errors=true",
        sites: "#{base}/schools?display_errors=true",
        study_sites: (course.provider&.study_sites&.none? ? "#{provider_base}/study-sites" : "#{base}/study-sites").to_s,
        accrediting_provider:,
        applications_open_from: "#{base}/applications-open",
        a_level_subject_requirements: publish_provider_recruitment_cycle_course_a_levels_what_a_level_is_required_path(
          course.provider_code,
          course.provider.recruitment_cycle_year,
          course.course_code,
          display_errors: true
        ),
        accept_pending_a_level: publish_provider_recruitment_cycle_course_a_levels_consider_pending_a_level_path(
          course.provider_code,
          course.provider.recruitment_cycle_year,
          course.course_code,
          display_errors: true
        ),
        accept_a_level_equivalency: publish_provider_recruitment_cycle_course_a_levels_a_level_equivalencies_path(
          course.provider_code,
          course.provider.recruitment_cycle_year,
          course.course_code,
          display_errors: true
        )
      }.with_indifferent_access[field]
    end
  end

  def provider_enrichment_error_url(provider:, field:)
    base = "/publish/organisations/#{provider.provider_code}/#{provider.recruitment_cycle_year}"

    {
      'train_with_us' => "#{base}/about?display_errors=true#provider_train_with_us",
      'train_with_disability' => "#{base}/about?display_errors=true#provider_train_with_disability",
      'email' => "#{base}/contact?display_errors=true#provider_email",
      'website' => "#{base}/contact?display_errors=true#provider_website",
      'telephone' => "#{base}/contact?display_errors=true#provider_telephone",
      'address1' => "#{base}/contact?display_errors=true#provider_address1",
      'address3' => "#{base}/contact?display_errors=true#provider_address3",
      'town' => "#{base}/contact?display_errors=true#provider_town",
      'address4' => "#{base}/contact?display_errors=true#provider_address4",
      'postcode' => "#{base}/contact?display_errors=true#provider_postcode"
    }[field]
  end

  # def environment_colour
  #  return "purple" if sandbox_mode?

  #  {
  #    "development" => "grey",
  #    "qa" => "orange",
  #    "review" => "purple",
  #    "rollover" => "turquoise",
  #    "staging" => "red",
  #    "unknown-environment" => "yellow",
  #  }[Settings.environment.selector_name]
  # end

  # def environment_label
  #  Settings.environment.label
  # end

  # def environment_header_class
  #  "app-header--#{Settings.environment.selector_name}"
  # end

  # def sandbox_mode?
  #  Settings.environment.selector_name == "sandbox"
  # end

  ## Ad-hoc, informally specified, and bug-ridden Ruby implementation of half
  ## of https://github.com/JedWatson/classnames.
  ##
  ## Example usage:
  ##   <input class="<%= cns("govuk-input", "govuk-input--width-10": is_small) %>">
  def classnames(*args)
    args.reduce('') do |str, arg|
      classes =

        case arg
        when Hash
          arg.reduce([]) { |cs, (classname, condition)| cs + [condition ? classname : nil] }
        when String
          [arg]
        else
          []
        end
      ([str] + classes).compact_blank.join(' ')
    end
  end

  alias cns classnames

  def x_provider_url(course)
    if preview?(params)
      provider_publish_provider_recruitment_cycle_course_path(
        course.provider_code,
        course.recruitment_cycle_year,
        course.course_code
      )
    else
      find_provider_path(course.provider_code, course.course_code)
    end
  end

  def x_accrediting_provider_url(course)
    if preview?(params)
      if Settings.features.provider_partnerships
        ratified_by_publish_provider_recruitment_cycle_course_path(
          course.provider_code,
          course.recruitment_cycle_year,
          course.course_code
        )
      else
        accredited_by_publish_provider_recruitment_cycle_course_path(
          course.provider_code,
          course.recruitment_cycle_year,
          course.course_code
        )
      end
    else
      find_accrediting_provider_path(course.provider_code, course.course_code)
    end
  end

  def x_accredited_partnerships_navigation_item_link_path(provider)
    if Settings.features.provider_partnerships
      support_recruitment_cycle_provider_accredited_partnerships_path(provider.recruitment_cycle_year, provider)
    else
      support_recruitment_cycle_provider_accredited_providers_path(provider.recruitment_cycle_year, provider)
    end
  end

  private

  def base_errors_hash(provider_code, course)
    {
      'Select if student visas can be sponsored' =>
        student_visa_publish_provider_recruitment_cycle_path(provider_code, course.recruitment_cycle_year),
      'Select if skilled worker visas can be sponsored' =>
        skilled_worker_visa_publish_provider_recruitment_cycle_path(provider_code, course.recruitment_cycle_year),
      'You must provide a Unique Reference Number (URN) for all course schools' =>
        schools_publish_provider_recruitment_cycle_course_path(provider_code, course.recruitment_cycle_year, course.course_code),
      'Enter a Unique Reference Number (URN) for all course schools' =>
        schools_publish_provider_recruitment_cycle_course_path(provider_code, course.recruitment_cycle_year, course.course_code),
      'You must provide a UK provider reference number (UKPRN)' =>
        contact_publish_provider_recruitment_cycle_path(provider_code, course.recruitment_cycle_year),
      'You must provide a UK provider reference number (UKPRN) and URN' =>
        contact_publish_provider_recruitment_cycle_path(provider_code, course.recruitment_cycle_year),
      'Enter a UK Provider Reference Number (UKPRN)' =>
        contact_publish_provider_recruitment_cycle_path(provider_code, course.recruitment_cycle_year),
      'Enter a UK Provider Reference Number (UKPRN) and URN' =>
        contact_publish_provider_recruitment_cycle_path(provider_code, course.recruitment_cycle_year),
      'Enter degree requirements' =>
        degrees_start_publish_provider_recruitment_cycle_course_path(provider_code, course.recruitment_cycle_year, course.course_code, display_errors: true),
      'Enter GCSE requirements' =>
        gcses_pending_or_equivalency_tests_publish_provider_recruitment_cycle_course_path(provider_code, course.recruitment_cycle_year, course.course_code, display_errors: true)
    }
  end
end
