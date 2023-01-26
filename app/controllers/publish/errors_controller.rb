# frozen_string_literal: true

module Publish
  class ErrorsController < ApplicationController
    skip_before_action :authenticate

    include Errorable

    layout "publish"
  end
end
