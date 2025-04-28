# frozen_string_literal: true

class AccreditedProviderComponent < ViewComponent::Base
  include PublishHelper

  attr_reader :provider, :remove_path

  def initialize(provider:, remove_path:)
    super
    @provider = provider
    @remove_path = remove_path
  end
end
