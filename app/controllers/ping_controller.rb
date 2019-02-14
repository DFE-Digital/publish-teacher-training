class PingController < ApplicationController
  skip_before_action :authenticate

  # this is for quick testing of api/db stability without needing to authorise
  def index
    render json: { course_count: Course.count }
  end
end
