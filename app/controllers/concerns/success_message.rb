# frozen_string_literal: true

module SuccessMessage
  extend ActiveSupport::Concern

  def course_updated_message(value)
    raise TypeError unless value.is_a?(String)

    flash[:success] = I18n.t('success.saved', value:)
  end

  def schools_added_message(schools)
    items_added = schools.size > 1 ? "#{schools.size} schools" : '1 school'
    flash[:success] = I18n.t('success.added', items_added:)
  end
end
