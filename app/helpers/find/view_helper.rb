# frozen_string_literal: true

module Find
  module ViewHelper
    def protect_against_mistakes
      if session[:confirmed_environment_at] && session[:confirmed_environment_at] > 5.minutes.ago
        yield
      else
        govuk_link_to 'Confirm environment to make changes', find_confirm_environment_path(from: request.fullpath)
      end
    end

    def permitted_referrer?
      return false if request.referer.blank?

      request.referer.include?(request.host_with_port) ||
        Settings.find_valid_referers.any? { |url| request.referer.start_with?(url) }
    end

    def course_back_link
      referer = URI(request.referer)
      if referer.request_uri =~ %r{^/results}

        request.referer
      elsif referer && session[:results_path] =~ %r{^/results}
        session[:results_path]
      end
    end
  end
end
