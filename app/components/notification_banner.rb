# frozen_string_literal: true

class NotificationBanner < ApplicationComponent
  attr_reader :text, :title_id, :text_body

  SUCCESS_TITLE = "Success"
  DEFAULT_TITLE = "Important"

  SUCCESS_ROLE = "alert"
  DEFAULT_ROLE = "region"

  DEFAULT_CLASS = "govuk-notification-banner"

  def initialize(
    title_text: nil,
    text: nil,
    text_body: nil,
    type: nil,
    role: nil,
    title_id: nil,
    disable_auto_focus: false,
    classes: [],
    html_attributes: {}
  )
    super(classes:, html_attributes:)
    @title_text = title_text
    @text = text
    @text_body = text_body
    @type = type
    @role = role
    @title_id = title_id || "#{DEFAULT_CLASS}-title"
    @disable_auto_focus = disable_auto_focus
  end

private

  attr_reader :title_text, :role, :type, :disable_auto_focus

  def default_classes
    [DEFAULT_CLASS]
  end

  def type_class
    "#{DEFAULT_CLASS}--#{type}"
  end

  def title
    return title_text if title_text
    return SUCCESS_TITLE if success_banner?

    DEFAULT_TITLE
  end

  def role_attribute
    return role if role
    # If type is success, add `role="alert"` to prioritise the information in
    # the notification banner to users of assistive technologies
    return SUCCESS_ROLE if success_banner?

    # Otherwise add `role="region"` to make the notification banner a landmark
    # to help users of assistive technologies to navigate to the banner
    DEFAULT_ROLE
  end

  def data_attributes
    attrs = { module: DEFAULT_CLASS }
    attrs[:disable_auto_focus] = disable_auto_focus if disable_auto_focus
    attrs
  end

  def success_banner?
    type&.to_sym == :success
  end
end
