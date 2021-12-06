module ViewHelper
  # def govuk_back_link_to(url = :back, body = "Back")
  #   render GovukComponent::BackLinkComponent.new(
  #     text: body,
  #     href: url,
  #     classes: "govuk-!-display-none-print",
  #     html_attributes: {
  #       data: {
  #         qa: "page-back",
  #       },
  #     },
  #   )
  # end

  # def search_ui_url(relative_path)
  #   URI.join(Settings.search_ui.base_url, relative_path).to_s
  # end

  # def search_ui_course_page_url(provider_code:, course_code:)
  #   search_ui_url("/course/#{provider_code}/#{course_code}")
  # end

  def bat_contact_email_address
    Settings.support_email
  end

  def bat_contact_email_address_with_wrap
    # https://developer.mozilla.org/en-US/docs/Web/HTML/Element/wbr
    # The <wbr> element will not be copied when copying and pasting the email address
    bat_contact_email_address.gsub("@", "<wbr>@").html_safe
  end

  def bat_contact_mail_to(name = nil, **kwargs)
    govuk_mail_to bat_contact_email_address, name || bat_contact_email_address_with_wrap, **kwargs
  end

  # def feedback_link_to
  #  t("feedback.link")
  # end

  def title_with_error_prefix(title, error)
   "#{t('page_titles.error_prefix') if error}#{title}"
  end

  # def enrichment_error_url(provider_code:, course:, field:, message: nil)
  #  base = "/organisations/#{provider_code}/#{course.recruitment_cycle_year}/courses/#{course.course_code}"

  #  if field.to_sym == :base
  #    base_errors_hash(provider_code, course)[message]
  #  else
  #    {
  #      about_course: "#{base}/about?display_errors=true#about_course_wrapper",
  #      how_school_placements_work: "#{base}/about?display_errors=true#how_school_placements_work_wrapper",
  #      fee_uk_eu: "#{base}/fees?display_errors=true#fee_uk_eu-error",
  #      course_length: "#{base + (course.has_fees? ? '/fees' : '/salary')}?display_errors=true#course_length-error",
  #      salary_details: "#{base}/salary?display_errors=true#salary_details-error",
  #      required_qualifications: "#{base}/requirements?display_errors=true#required_qualifications_wrapper",
  #      age_range_in_years: "#{base}/age-range?display_errors=true",
  #    }.with_indifferent_access[field]
  #  end
  # end

  # def provider_enrichment_error_url(provider:, field:)
  #  base = "/organisations/#{provider.provider_code}/#{provider.recruitment_cycle_year}"

  #  {
  #    "train_with_us" => "#{base}/about?display_errors=true#provider_train_with_us",
  #    "train_with_disability" => "#{base}/about?display_errors=true#provider_train_with_disability",
  #    "email" => "#{base}/contact?display_errors=true#provider_email",
  #    "website" => "#{base}/contact?display_errors=true#provider_website",
  #    "telephone" => "#{base}/contact?display_errors=true#provider_telephone",
  #    "address1" => "#{base}/contact?display_errors=true#provider_address1",
  #    "address3" => "#{base}/contact?display_errors=true#provider_address3",
  #    "address4" => "#{base}/contact?display_errors=true#provider_address4",
  #    "postcode" => "#{base}/contact?display_errors=true#provider_postcode",
  #  }[field]
  # end

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
  # def classnames(*args)
  #  args.reduce("") do |str, arg|
  #    classes =
  #
  #      if arg.is_a? Hash
  #        arg.reduce([]) { |cs, (classname, condition)| cs + [condition ? classname : nil] }
  #      elsif arg.is_a? String
  #        [arg]
  #      else
  #        []
  #      end
  #      #    ([str] + classes).reject(&:blank?).join(" ")
  #  end
  # end

  # alias_method :cns, :classnames

  # private

  # def base_errors_hash(provider_code, course)
  #  {
  #    "Select if visas can be sponsored" =>
  #      provider_recruitment_cycle_visas_path(provider_code, course.recruitment_cycle_year),
  #    "You must provide a Unique Reference Number (URN) for all course locations" =>
  #      provider_recruitment_cycle_sites_path(provider_code, course.recruitment_cycle_year),
  #    "Enter a Unique Reference Number (URN) for all course locations" =>
  #      provider_recruitment_cycle_sites_path(provider_code, course.recruitment_cycle_year),
  #    "You must provide a UK provider reference number (UKPRN)" =>
  #      provider_recruitment_cycle_references_path(provider_code, course.recruitment_cycle_year),
  #    "You must provide a UK provider reference number (UKPRN) and URN" =>
  #      provider_recruitment_cycle_references_path(provider_code, course.recruitment_cycle_year),
  #    "Enter a UK Provider Reference Number (UKPRN)" =>
  #      provider_recruitment_cycle_references_path(provider_code, course.recruitment_cycle_year),
  #    "Enter a UK Provider Reference Number (UKPRN) and URN" =>
  #      provider_recruitment_cycle_references_path(provider_code, course.recruitment_cycle_year),
  #    "Enter degree requirements" =>
  #      degrees_start_provider_recruitment_cycle_course_path(provider_code, course.recruitment_cycle_year, course.course_code),
  #    "Enter GCSE requirements" =>
  #      gcses_pending_or_equivalency_tests_provider_recruitment_cycle_course_path(provider_code, course.recruitment_cycle_year, course.course_code),
  #  }
  # end
end
