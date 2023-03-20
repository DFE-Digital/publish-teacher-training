# frozen_string_literal: true

module SuccessMessage
  extend ActiveSupport::Concern

  def course_updated_message(value)
    raise TypeError unless value.is_a?(String)

    flash[:success] = I18n.t('success.saved', value:)
  end

  def schools_added_message(locations)
    items_added = locations.size > 1 ? "#{locations.size} locations" : '1 location'
    flash[:success] = I18n.t('success.added', items_added:)
  end
end
