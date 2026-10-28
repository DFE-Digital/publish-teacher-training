# frozen_string_literal: true

module FindAndUseAnAPI
  class BuildManifest
    include ServicePattern

    MANIFEST_PATH = Rails.root.join("config/fauapi/manifest.json")
    API_SPEC_PATH = Rails.root.join("swagger/public_v1/api_spec.json")

    def call
      JSON.parse(MANIFEST_PATH.read).merge(
        "schema" => {
          "fileName" => API_SPEC_PATH.basename.to_s,
          "name" => API_SPEC_PATH.basename.to_s,
          "schemaType" => "openapi",
          "contentType" => "application/json",
          "documentContentValue" => Base64.strict_encode64(API_SPEC_PATH.binread),
        },
      )
    end
  end
end
