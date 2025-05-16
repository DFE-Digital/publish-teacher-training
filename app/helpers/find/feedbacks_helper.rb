module Find::FeedbacksHelper
  def feedback_url
    if Settings.features.gov_style_feedback_form_enabled
      new_find_feedback_path
    else
      "https://forms.office.com/e/LcMi76ZfHU"
    end
  end

  def feedback_new_tab?
    !Settings.features.gov_style_feedback_form_enabled
  end
end
