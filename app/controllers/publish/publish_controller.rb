module Publish
  class PublishController < ApplicationController
    layout "publish"

    after_action :verify_authorized
  end
end
