# frozen_string_literal: true

class PublicAPIController < ActionController::API
  include AbstractController::Translation
  include DfE::Analytics::Requests
  include Pagy::Backend
  include ErrorHandlers::Pagy
  include Pundit::Authorization
end
