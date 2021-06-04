# frozen_string_literal: true

module NotificationBanner
  class View < GovukComponent::Base
    attr_reader :text, :title_id

    SUCCESS_TITLE = "Success"
    DEFAULT_TITLE = "Important"

    SUCCESS_ROLE = "alert"
    DEFAULT_ROLE = "region"

    DEFAULT_CLASS = "govuk-notification-banner"

    def initialize(
      title_text: nil,
      text: nil,
      type: nil,
      classes: [],
      role: nil,
      title_id: nil,
      disable_auto_focus: false
    )
      super(classes: classes)
      @title_text = title_text
      @text = text
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
      "#{DEFAULT_CLASS}--#{type}" if success_banner?
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
      type == :success
    end
  end
end
