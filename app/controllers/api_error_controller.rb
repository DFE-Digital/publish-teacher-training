# frozen_string_literal: true

class APIErrorController < ActionController::API
  def error500
    raise 'This is an error that is triggered by the application when a user accesses the /error_500 route. If you are seeing this in logs, you can ignore it.'
  end

  def error_nodb
    raise PG::ConnectionBad, 'This is an error that is triggered by the application when a user accesses the /error_nodb route. If you are seeing this in logs, you can ignore it.'
  end
end
