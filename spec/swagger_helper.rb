require "rails_helper"

RSpec.configure do |config|
  config.before :suite do
    # Patch to ensure both rspec works and valid OpenAPI spec is generated
    # see https://github.com/jdanielian/open-api-rswag#global-metadata
    OpenApi::Rswag::Specs.config.swagger_docs["public_v1/api_spec.json"]["basePath"] = "/api/public/v1/"
  end

  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.swagger_root = Rails.root.join("swagger").to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under swagger_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a swagger_doc tag to the
  # the root example_group in your specs, e.g. describe '...', swagger_doc: 'v2/swagger.json'
  config.swagger_docs = {
    "public_v1/api_spec.json" => ActiveSupport::HashWithIndifferentAccess.new(YAML.load_file(Rails.root.join("swagger/public_v1/template.yml"))),
  }
end
