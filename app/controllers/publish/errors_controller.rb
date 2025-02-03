# frozen_string_literal: true

module Publish
  class ErrorsController < ApplicationController
    skip_before_action :authenticate
    skip_after_action :verify_authorized

    include Errorable
  end
end
