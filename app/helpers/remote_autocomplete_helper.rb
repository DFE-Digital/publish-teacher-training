# frozen_string_literal: true

# Builds the data attributes that wire a form group up to the
# `remote-autocomplete` Stimulus controller (app/javascript/shared).
module RemoteAutocompleteHelper
  # path:        suggestion endpoint the controller fetches from
  # format:      result formatter key (provider/school/accredited/location)
  # min_length:  characters required before the first request
  # id_field:    result attribute copied into the hidden field on select
  # hidden_name: name of the hidden field that receives the selected id
  def remote_autocomplete_data(path:, format: nil, min_length: 3, id_field: nil, hidden_name: nil)
    {
      controller: "remote-autocomplete",
      remote_autocomplete_path_value: path,
      remote_autocomplete_format_value: format,
      remote_autocomplete_min_length_value: min_length,
      remote_autocomplete_id_field_value: id_field,
      remote_autocomplete_hidden_name_value: hidden_name,
    }.compact
  end
end
