module PublishInterface
  class PublishInterfaceController < ApplicationController
    layout "publish_interface"

    after_action :verify_authorized
  end
end
