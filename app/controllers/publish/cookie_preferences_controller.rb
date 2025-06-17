# frozen_string_literal: true

module Publish
  class CookiePreferencesController < ApplicationController
    skip_before_action :authenticate
    skip_before_action :authorize_provider

    skip_after_action :verify_authorized
  end
end
