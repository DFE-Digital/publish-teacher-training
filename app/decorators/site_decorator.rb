# frozen_string_literal: true

class SiteDecorator < Draper::Decorator
  include PublishHelper
  delegate_all

  def full_address(join_on_separator = ", ")
    smart_quotes([object.address1, object.address2, object.address3, object.town, object.address4, object.postcode].compact_blank.join(join_on_separator).html_safe)
  end

  def full_address_on_seperate_lines
    full_address("<br>")
  end

  def location_name
    smart_quotes(super)
  end
end
