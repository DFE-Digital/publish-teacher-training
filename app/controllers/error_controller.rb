class ErrorController < ActionController::API
  def error_500
    raise "This is an error that is triggered by the application when a user accesses the /error_500 route. If you are seeing this in logs, you can ignore it."
  end
end
