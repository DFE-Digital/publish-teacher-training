# frozen_string_literal: true

class Provider::SchoolDecorator < Draper::Decorator
  include MarkdownHelper
  delegate_all

  delegate :urn, to: :gias_school

  def location_name
    smart_quotes(base_location_name)
  end

  delegate :site_code, to: :object

  def full_address_on_seperate_lines
    full_address("\n")
  end

private

  def base_location_name
    name = gias_school.name
    object.main_site? ? "#{name} (Main Site)" : name
  end

  def full_address(join_on_separator = ", ")
    smart_quotes(
      [
        gias_school.address1,
        gias_school.address2,
        gias_school.address3,
        gias_school.town,
        gias_school.county,
        gias_school.postcode,
      ].compact_blank.join(join_on_separator),
    )
  end

  def gias_school
    object.gias_school
  end
end
