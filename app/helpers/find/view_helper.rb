module Find
  module ViewHelper
    def protect_against_mistakes
      if session[:confirmed_environment_at] && session[:confirmed_environment_at] > 5.minutes.ago
        yield
      else
        govuk_link_to "Confirm environment to make changes", find_confirm_environment_path(from: request.fullpath)
      end
    end
  end
end
