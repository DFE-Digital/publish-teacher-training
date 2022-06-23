class PublicAPIController < ActionController::API
  include DfE::Analytics::Requests
  include Pagy::Backend
  include ErrorHandlers::Pagy
  include Pundit::Authorization
end
