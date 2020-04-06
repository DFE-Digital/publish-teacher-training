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
  swagger_v1_template = YAML.load_file(Rails.root.join("swagger/public_v1/template.yml"))
  swagger_v1_template["components"]["schemas"] ||= {}
  additional_component_schemas = Hash[
    Dir[Rails.root.join("swagger/public_v1/component_schemas/*.yml")].map do |path|
      component_name = File.basename(path, ".yml")
      [component_name, YAML.load_file(path)]
    end
  ]
  swagger_v1_template["components"]["schemas"].merge!(additional_component_schemas)
  swagger_v1_template["components"]["schemas"] = swagger_v1_template["components"]["schemas"].sort.to_h
  config.swagger_docs = {
    "public_v1/api_spec.json" => swagger_v1_template.with_indifferent_access,
  }
end
