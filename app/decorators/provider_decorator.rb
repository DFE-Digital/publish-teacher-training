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
end
