class ProviderDecorator < ApplicationDecorator
  delegate_all

  def accredited_bodies
    object.accredited_bodies.sort_by { |provider| provider["provider_name"] }.map do |provider|
      Struct.new(:provider_name, :provider_code, :description, keyword_init: true).new(provider)
    end
  end

  def website
    return if object.website.blank?

    object.website.start_with?("http") ? object.website : "http://#{object.website}"
  end

  def full_address
    address_lines.map { |line| ERB::Util.html_escape(line) }.join("<br> ").html_safe
  end

private

  def address_lines
    [
      object.address1,
      object.address2,
      object.address3,
      object.address4,
      object.postcode,
    ].compact_blank
  end
end
