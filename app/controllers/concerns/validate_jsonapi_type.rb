module ValidateJsonapiType
  extend ActiveSupport::Concern

  def validate_jsonapi_type(params, type)
    # jsonapi-rb doesn't appear to validate the type of data record that's
    # been given us, so even though we say "require(:session)" it won't
    # validate the type field of the data object that was passed through.
    #
    # So for now, we do this by hand.
    sent_type = params[:_jsonapi][:data][:type]
    unless sent_type == type
      raise ActionController::BadRequest.new(
        "data type '#{sent_type}' did not match expected type '#{type}'",
      )
    end
  end
end
