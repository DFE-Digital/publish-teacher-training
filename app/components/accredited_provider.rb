# frozen_string_literal: true

class AccreditedProvider < ViewComponent::Base
  attr_reader :provider_name, :remove_path, :about_accredited_provider, :change_about_accredited_provider_path

  def initialize(provider_name:, remove_path:, about_accredited_provider:, change_about_accredited_provider_path:)
    super
    @provider_name = provider_name
    @remove_path = remove_path
    @about_accredited_provider = about_accredited_provider
    @change_about_accredited_provider_path = change_about_accredited_provider_path
  end
end
