# frozen_string_literal: true

# Blazer::BaseController is defined inside `module Blazer` and inherits from the
# unqualified `ApplicationController`, so Ruby resolves it to this class rather
# than the top-level one. Blazer then calls `current_user` on it to attribute
# queries, dashboards and audits. Without this, `Blazer.user_method` finds no
# `current_user` and silently records nothing.
module Blazer
  class ApplicationController < ::ApplicationController
    def current_user
      @current_user ||= UserFromCookie.authenticated_user(request)
    end
  end
end
