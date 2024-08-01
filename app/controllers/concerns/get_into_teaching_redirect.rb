# frozen_string_literal: true

module GetIntoTeachingRedirect
  extend ActiveSupport::Concern

  def git_redirect
    redirect_to I18n.t("get_into_teaching.#{git_url_locale_key}"), allow_other_host: true
  end

  private

  def git_path_param
    params[:git_path]
  end

  def git_url_locale_key
    "url_#{git_path_param}"
  end
end
