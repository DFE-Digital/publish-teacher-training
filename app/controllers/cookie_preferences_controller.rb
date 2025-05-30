# frozen_string_literal: true

class CookiePreferencesController < ApplicationController
  skip_before_action :authenticate
end
