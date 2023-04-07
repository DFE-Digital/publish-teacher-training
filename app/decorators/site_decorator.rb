# frozen_string_literal: true

class SiteDecorator < Draper::Decorator
  delegate_all

  def full_address(join_on_separator = ', ')
    [object.address1, object.address2, object.town, object.address4, object.postcode].compact_blank.join(join_on_separator).html_safe
  end

  def full_address_on_seperate_lines
    full_address('<br>')
  end
end
