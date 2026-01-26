module ProvidersOnboardingFormRequestsHelper
  def given_i_am_authenticated
    sign_in_system_test(user:)
  end

  def when_i_navigate_to_the_providers_onboarding_form_requests_page
    visit support_root_path
    click_link "Onboarding"
  end

  def when_i_visit_the_providers_onboarding_form_requests_page
    visit support_providers_onboarding_form_requests_path
  end
  alias_method :then_i_am_on_the_providers_onboarding_form_requests_page, :when_i_visit_the_providers_onboarding_form_requests_page

  def then_i_see_providers_onboarding_form_requests_table
    expect(page).to have_content("Provider Onboarding Requests")
    expect(page).to have_content("Id")
    expect(page).to have_content("Form name")
    expect(page).to have_content("Status")
    expect(page).to have_content("Created at")
  end

  def then_i_see_recent_providers_onboarding_form_requests_entries
    ProvidersOnboardingFormRequest.order(created_at: :desc).limit(10).each do |request|
      expect(page).to have_content(request.id)
      expect(page).to have_content(request.form_name)
      expect(page).to have_content(request.support_agent.present? ? request.support_agent.name : "Unassigned")
      expect(page).to have_content(request.status.titleize)
      expect(page).to have_content(request.created_at.strftime("%-d %B %Y"))
    end
  end

  def then_i_see_backlink_to_support_homepage
    expect(page).to have_link("Back", href: support_root_path)
  end

  def then_i_am_on_the_support_homepage
    expect(page).to have_current_path(support_recruitment_cycle_providers_path(Find::CycleTimetable.current_year))
  end

  def then_i_see_first_page_of_requests_with_pagination
    expect(page).to have_selector("table tbody tr", count: 10)
    expect(page).to have_link("Next")
  end

  def then_i_see_second_page_of_requests_with_pagination
    expect(page).to have_selector("table tbody tr", count: 8)
    expect(page).to have_link("Previous")
  end

  def then_i_see_the_generate_onboarding_form_button
    expect(page).to have_link("Generate onboarding form", href: new_support_providers_onboarding_form_request_path)
    expect(page).to have_css(".govuk-button", text: "Generate onboarding form")
  end

  def when_i_click_to_generate_a_new_onboarding_form
    click_link_or_button "Generate onboarding form"
  end

  def then_i_am_on_new_onboarding_form_request_page
    expect(page).to have_current_path(new_support_providers_onboarding_form_request_path)
  end

  def then_i_am_on_providers_onboarding_form_requests_listing_page
    expect(page).to have_current_path(support_providers_onboarding_form_requests_path)
  end

  def then_i_am_on_the_provider_onboarding_details_page(request)
    expect(page).to have_current_path(
      support_providers_onboarding_form_request_path(request),
    )
  end

  def then_i_see_fields_on_new_onboarding_form_request_page
    expect(page).to have_current_path(new_support_providers_onboarding_form_request_path)
    expect(page).to have_content("Generate a new provider onboarding request")
    expect(page).to have_field("Form name")
    expect(page).to have_field("Support agent (optional)")
    expect(page).to have_field("Zendesk link (optional)")
  end

  def then_i_click_back_button
    click_link_or_button "Back"
  end

  def then_i_click_submit_button
    click_link_or_button "Submit"
  end

  def then_i_click_cancel
    click_link "Cancel"
  end

  def then_i_see_validation_error_message_for_missing_form_name
    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Enter a name for the onboarding form. This is for internal reference only.")
    expect(page).to have_css(".govuk-error-summary")
  end

  def then_last_request_has_valid_uuid
    expect(ProvidersOnboardingFormRequest.last.form_link).to match(/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/)
  end

  def then_i_see_success_message_with_form_link(form_name:)
    expect(page).to have_content("Onboarding form generated successfully for #{form_name}")
  end

  def then_i_see_form_name_and_link(request)
    expect(page).to have_content(request.form_name)
    expect(page).to have_link(
      "View provider form",
      href: publish_provider_onboarding_path(request.uuid),
    )
  end

  def then_i_expect_support_agent_and_zendesk_link_to_be_blank
    expect(ProvidersOnboardingFormRequest.last.support_agent).to be_blank
    expect(ProvidersOnboardingFormRequest.last.zendesk_link).to be_blank
  end

  def then_i_expect_zendesk_link_to_be_blank
    expect(ProvidersOnboardingFormRequest.last.zendesk_link).to be_blank
  end

  def then_i_expect_support_agent_to_be_blank
    expect(ProvidersOnboardingFormRequest.last.support_agent).to be_blank
  end

  def then_i_do_not_see_non_admin_user_in_support_agent_dropdown(non_admin_user)
    expect(page).not_to have_select(
      "Support agent (optional)",
      with_options: [non_admin_user.email],
    )
  end

  def when_i_visit_the_show_page_for(onboarding_request)
    visit support_providers_onboarding_form_request_path(onboarding_request)
  end

  def then_i_am_on_the_show_page_for(onboarding_request)
    expect(page).to have_current_path(support_providers_onboarding_form_request_path(onboarding_request))
  end

  def then_i_see_all_provider_details_for(onboarding_request)
    # Page heading
    expect(page).to have_content("Provider details")
    expect(page).to have_content(onboarding_request.form_name)
    # Onboadring details
    expect(page).to have_content("Form link")
    expect(page).to have_content("Zendesk link")
    # Organisation details
    expect(page).to have_content("Provider name")
    expect(page).to have_content(onboarding_request.provider_name)
    expect(page).to have_content("UK provider reference number (UKPRN)")
    expect(page).to have_content(onboarding_request.ukprn)
    expect(page).to have_content("Is the organisation an accredited provider?")
    expect(page).to have_content(onboarding_request.accredited_provider ? "Yes" : "No")
    expect(page).to have_content("Unique reference number (URN)")
    expect(page).to have_content(onboarding_request.urn)
    # Contact details
    expect(page).to have_content("Contact email address")
    expect(page).to have_content(onboarding_request.contact_email_address)
    expect(page).to have_content("Telephone number")
    expect(page).to have_content(onboarding_request.telephone)
    expect(page).to have_content("Website")
    expect(page).to have_content(onboarding_request.website)
    # Address (check each line separately for multi-line rendering)
    expect(page).to have_content(onboarding_request.address_line_1)
    expect(page).to have_content(onboarding_request.address_line_2)
    expect(page).to have_content(onboarding_request.town_or_city)
    expect(page).to have_content(onboarding_request.postcode)
    # User details
    expect(page).to have_content("Email address")
    expect(page).to have_content(onboarding_request.email_address)
    expect(page).to have_content("First name")
    expect(page).to have_content(onboarding_request.first_name)
    expect(page).to have_content("Last name")
    expect(page).to have_content(onboarding_request.last_name)
  end

  def then_i_see_action_buttons_and_cancel_link
    expect(page).to have_button("Accept")
    expect(page).to have_button("Reject")
    expect(page).to have_link("Cancel", href: support_providers_onboarding_form_requests_path)
  end

  def when_i_click_accept
    click_button "Accept"
  end

  def when_i_click_reject
    click_button "Reject"
  end

  def then_status_should_be(updated_status, onboarding_request)
    within("tr", text: onboarding_request.form_name) do
      expect(page).to have_content(updated_status)
    end
  end
end
