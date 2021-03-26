# frozen_string_literal: true

class PageTitle::View < GovukComponent::Base
  I18N_FORMAT = /^\S*\.\S*$/.freeze

  attr_accessor :title

  def initialize(title: "", has_errors: false)
    @title = title
    @has_errors = has_errors
  end

  def build_page_title
    [build_error + build_title + build_service_name, "GOV.UK"].join(" - ")
  end

private

  attr_reader :has_errors

  def build_error
    has_errors ? "Error: " : ""
  end

  def build_title
    title.match?(I18N_FORMAT) ? I18n.t("components.page_titles." + title) : title
  end

  def build_service_name
    title.present? ? " - " + I18n.t("service_name") : I18n.t("service_name")
  end
end
