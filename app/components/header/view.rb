# frozen_string_literal: true

class Header::View < GovukComponent::Base
  attr_reader :service_name, :items

  include ActiveModel

  def initialize(service_name:, items: nil)
    @service_name = service_name
    @items = items
  end

  def header_class
    klass = "govuk-header__content app-header__content"
    klass += " app-header__content--single-item" if items.length == 1
    klass
  end
end
