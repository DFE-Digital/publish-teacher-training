module SuccessMessage
  extend ActiveSupport::Concern

  def details_flash_message(value)
    raise TypeError unless value.is_a?(String)

    flash[:success] = @course.is_published? ? I18n.t("success.value_published", value: value) : I18n.t("success.value_saved", value: value)
  end

  def flash_message(value)
    raise TypeError unless value.is_a?(String)

    flash[:success] = @course.only_published? ? I18n.t("success.value_published", value: value) : I18n.t("success.value_saved", value: value)
  end
end
