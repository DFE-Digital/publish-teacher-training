class PublicAPIController < ActionController::API
  include EmitsRequestEvents
  include Pagy::Backend
  include ErrorHandlers::Pagy
end
