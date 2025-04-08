# frozen_string_literal: true

class ProviderDecorator < ApplicationDecorator
  delegate_all

  def accredited_partners
    object.accredited_partners.order(provider_name: :asc)
  end

  def website
    return if object.website.blank?

    object.website.start_with?("http") ? object.website : "http://#{object.website}"
  end

  def full_address
    address_lines.map { |line| ERB::Util.html_escape(line) }.join("<br> ").html_safe
  end

  def name_and_code
    "#{object.provider_name} (#{object.provider_code})"
  end

  def name_was_and_code
    "#{object.provider_name_was} (#{object.provider_code})"
  end

private

  def address_lines
    [
      object.address1,
      object.address2,
      object.address3,
      object.town,
      object.address4,
      object.postcode,
    ].compact_blank
  end
end
