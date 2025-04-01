# frozen_string_literal: true

module Find
  module ViewHelper
    def permitted_referrer?
      return false if request.referer.blank?

      [*Settings.find_hosts, *Settings.publish_hosts].include?(referer.host)
    end

    def course_back_link
      if referer.request_uri =~ %r{^/results}
        request.referer
      elsif referer && session[:results_path] =~ %r{^/results}
        session[:results_path]
      end
    end

  private

    def referer
      URI.parse(request.referer)
    end
  end
end
