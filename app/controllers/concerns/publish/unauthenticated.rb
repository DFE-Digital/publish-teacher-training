# frozen_string_literal: true

module Publish
  module Unauthenticated
    extend ActiveSupport::Concern

    included do
      skip_before_action :authenticate
      skip_after_action :verify_authorized
      skip_before_action :authorize_provider
    end
  end
end
