class ErrorController < ActionController::API
  def error_500
    raise "This is an error that is triggered by the application when a user accesses the /error_500 route. If you are seeing this in logs, you can ignore it."
  end

  def error_nodb
    raise PG::ConnectionBad.new("This is an error that is triggered by the application when a user accesses the /error_nodb route. If you are seeing this in logs, you can ignore it.")
  end
end
