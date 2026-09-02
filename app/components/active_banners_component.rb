# frozen_string_literal: true

class ActiveBannersComponent < ViewComponent::Base
  INTERFACE_SCOPES = {
    find: :display_on_find,
    publish: :display_on_publish,
    support: :display_on_support,
  }.freeze

  def initialize(interface:)
    super()

    @interface = interface
  end

  def render?
    banners.any?
  end

private

  attr_reader :interface

  def banners
    @banners ||= Banner.public_send(INTERFACE_SCOPES.fetch(interface.to_sym)).active.active_order.to_a
  end
end
