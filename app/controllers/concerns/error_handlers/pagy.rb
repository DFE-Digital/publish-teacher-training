module ErrorHandlers
  module Pagy
    def self.included(base)
      base.include(ErrorHandlers::Base)

      base.class_eval do
        rescue_from ::Pagy::OverflowError do |_exception|
          render_json_error(status: 400, message: I18n.t("pagy.overflow"))
        end
      end
    end
  end
end
