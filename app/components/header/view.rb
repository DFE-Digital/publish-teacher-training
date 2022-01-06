# frozen_string_literal: true

class Header::View < GovukComponent::Base
  attr_reader :service_name, :current_user, :items

  include ActiveModel

  def initialize(service_name:, current_user: nil, items: nil)
    super(classes: classes, html_attributes: html_attributes)
    @service_name = service_name
    @current_user = current_user
    @items = items
  end

  def header_class
    klass = "govuk-header__content app-header__content"
    klass += " app-header__content--single-item" if items.length == 1
    klass
  end

  def environment_header_class
    "app-header--#{Settings.environment.name}"
  end

  # TODO: replace this with the notifications path helper once notifications
  # have been migrated from Old Publish.
  def old_publish_notifications_path
    "#{Settings.publish_url}/notifications"
  end

  # TODO: replace this with the root path of the Publish interface as one of
  # the last steps in migrating Publish functionality into this codebase.
  def old_publish_homepage_path
    Settings.publish_url
  end
end
