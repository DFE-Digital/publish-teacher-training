# frozen_string_literal: true

class ProvidersOnboardingFormRequestDecorator < Draper::Decorator
  delegate_all

  def full_address(join_on_separator = ", ")
    [object.address_line_1,
     object.address_line_2,
     object.address_line_3,
     object.town_or_city,
     object.postcode]
      .compact_blank
      .join(join_on_separator)
  end

  def full_address_on_separate_lines
    full_address("\n")
  end
end
