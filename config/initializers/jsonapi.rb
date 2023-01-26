def page_url(page:)
  params.then do |new_params|
    new_params[:page] = {} unless new_params.key? :page
    new_params[:page][:page] = page
    url_for(new_params.to_unsafe_h.merge(only_path: true))
  end
end

JSONAPI::Rails.configure do |config|
  # Set a default serializable class mapping.
  config.jsonapi_class = Hash.new do |h, k|
    names = k.to_s.split("::")
    klass = names.pop

    h[k] = [
      "API::V3::Serializable#{klass}",
      [*names, klass].join("::"),
    ].lazy
      .map(&:safe_constantize)
      .detect(&:present?)
  end

  # # Set a default serializable class mapping for errors.
  # config.jsonapi_errors_class = Hash.new { |h, k|
  #   names = k.to_s.split('::')
  #   klass = names.pop
  #   h[k] = [*names, "Serializable#{klass}"].join('::').safe_constantize
  # }.tap { |h|
  #   h[:'ActiveModel::Errors'] = JSONAPI::Rails::SerializableActiveModelErrors
  #   h[:Hash] = JSONAPI::Rails::SerializableErrorHash
  # }
  #
  # # Set a default JSON API object.
  # config.jsonapi_object = {
  #   version: '1.0'
  # }
  #
  # # Set default exposures.
  # # A lambda/proc that will be eval'd in the controller context.
  # config.jsonapi_expose = lambda {
  #   { url_helpers: ::Rails.application.routes.url_helpers }
  # }
  #
  # # Set a default pagination scheme.
  config.jsonapi_pagination = lambda { |collection|
    {}.tap do |links|
      links[:next] = page_url(page: collection.next_page) if collection.respond_to?(:next_page) && collection.next_page.present?

      links[:prev] = page_url(page: collection.prev_page) if collection.respond_to?(:prev_page) && collection.prev_page.present?

      links[:last] = page_url(page: [collection.total_pages - 1, 1].max) if collection.respond_to?(:total_pages)
    end
  }
  #
  # # Set a logger.
  # config.logger = Logger.new(STDOUT)
  #
  # Uncomment the following to disable logging.
  # config.logger = Logger.new(STDOUT)

  # This might be the right thing to do. It cleans up logging in the test env,
  # at the very least, and seems to dump the logs into `log/test.log` as would
  # be expected.
  config.logger = Rails.logger
end
