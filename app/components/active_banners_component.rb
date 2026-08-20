# frozen_string_literal: true

class ActiveBannersComponent < ViewComponent::Base
  INTERFACE_SCOPES = {
    find: :display_on_find,
    publish: :display_on_publish,
    support: :display_on_support,
  }.freeze

  def initialize(interface:, flash:)
    super()

    @interface = interface
    @flash = flash
  end

  def render?
    flash.empty? && banners.any?
  end

private

  attr_reader :interface, :flash

  def banners
    @banners ||= Banner.public_send(INTERFACE_SCOPES.fetch(interface.to_sym)).active.active_order
  end
end
