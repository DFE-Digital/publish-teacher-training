# frozen_string_literal: true

module Find
  module OneLoginHelper
    def one_login_path
      if Settings.one_login.enabled
        "/auth/one-login"
      else
        "/auth/find-developer"
      end
    end
  end
end
