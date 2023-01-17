module Publish
  class ErrorsController < ApplicationController
    skip_before_action :authenticate

    include Errorable

    layout "publish"
  end
end
