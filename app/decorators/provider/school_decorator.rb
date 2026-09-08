# frozen_string_literal: true

class Provider::SchoolDecorator < Draper::Decorator
  include MarkdownHelper
  delegate_all

  def full_address(join_on_separator = ", ")
    smart_quotes(object.full_address(join_on_separator))
  end

  def full_address_on_seperate_lines
    full_address("\n")
  end

  def location_name
    smart_quotes(object.location_name)
  end

  delegate :code, to: :object

  delegate :urn, to: :object
end
