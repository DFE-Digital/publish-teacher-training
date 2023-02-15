# frozen_string_literal: true

module SuccessMessage
  extend ActiveSupport::Concern

  def course_updated_message(value)
    raise TypeError unless value.is_a?(String)

    flash[:success] = I18n.t('success.saved', value:)
  end
end
