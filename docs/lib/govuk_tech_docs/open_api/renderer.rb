# frozen_string_literal: true

require "erb"
require "json"
require "rouge"

module GovukTechDocs
  module OpenApi
    class Renderer
      attr_reader :app, :document

      def initialize(app, document)
        @app = app
        @document = document

        # Load template files
        @template_api_full = get_renderer("api_reference_full.html.erb")
        @template_path = get_renderer("path.html.erb")
        @template_schema = get_renderer("schema.html.erb")
        @template_operation = get_renderer("operation.html.erb")
        @template_parameters = get_renderer("parameters.html.erb")
        @template_responses = get_renderer("responses.html.erb")
        @template_any_of = get_renderer("any_of.html.erb")
        @template_curl_examples = get_renderer("curl_examples.html.erb")
      end

      def api_full
        paths = ""
        paths_data = @document.paths
        paths_data.each do |path_data|
          # For some reason paths.each returns an array of arrays [title, object]
          # instead of an array of objects
          text = path_data[0]
          paths += path(text)
        end
        schemas = ""
        schemas_data.each do |schema_data|
          text = schema_data[0]
          schemas += schema(text)
        end
        @template_api_full.result(binding)
      end

      def path(text)
        path = @document.paths[text]
        id = text.parameterize
        operations = operations(text: text, path: path, path_id: id)
        @template_path.result(binding)
      end

      def schema(text)
        properties = properties_for_schema(text)

        schema_data = schemas_data.find { |s| s[0] == text }

        title = schema_data[0]
        schema = schema_data[1]

        return @template_any_of.result(binding) if schema_data[1]["anyOf"]

        @template_schema.result(binding)
      end

      def schemas_from_path(text)
        path = @document.paths[text]
        operations = get_operations(path)
        # Get all referenced schemas
        schemas = []
        operations.compact.each_value do |operation|
          responses = operation.responses
          responses.each_value do |response|
            next unless response.content["application/json"]

            schema = response.content["application/json"].schema
            schema_name = get_schema_name(schema.node_context.source_location.to_s)
            schemas.push schema_name unless schema_name.nil?
            schemas.concat(schemas_from_schema(schema))
          end
        end
        # Render all referenced schemas
        output = ""
        schemas.uniq.each do |schema_name|
          output += schema(schema_name)
        end
        output.prepend('<h2 id="schemas">Schemas</h2>') unless output.empty?
        output
      end

      def schemas_from_schema(schema)
        schemas = []
        properties = schema.properties.pluck(1)
        properties.push schema.items if schema.type == "array"
        all_of = schema["allOf"]
        if all_of.present?
          all_of.each do |schema_nested|
            schema_nested.properties.each do |property|
              properties.push property[1]
            end
          end
        end
        properties.each do |property|
          # Must be a schema be referenced by another schema
          # And not a property of a schema
          if property.node_context.referenced_by.to_s.include?("#/components/schemas") &&
              property.node_context.source_location.to_s.exclude?("/properties/")
            schema_name = get_schema_name(property.node_context.source_location.to_s)
          end
          schemas.push schema_name unless schema_name.nil?
          # Check sub-properties for references
          schemas.concat(schemas_from_schema(property))
        end
        schemas
      end

      def operations(text:, path:, path_id:)
        output = ""
        operations = get_operations(path)
        operations.compact.each do |key, operation|
          id = "#{path_id}-#{key.parameterize}"
          parameters = parameters(operation, id)
          responses = responses(operation, id)
          curl_examples = curl_examples(operation, id)
          output += @template_operation.result(binding)
        end
        output
      end

      def parameters(operation, operation_id)
        parameters = operation.parameters
        id = "#{operation_id}-parameters"
        @template_parameters.result(binding)
      end

      def curl_examples(operation, operation_id)
        curl_examples = operation.node_data["x-curl-examples"] || []
        id = "#{operation_id}-curl-examples"
        @template_curl_examples.result(binding)
      end

      def responses(operation, operation_id)
        responses = operation.responses
        id = "#{operation_id}-responses"
        @template_responses.result(binding)
      end

      def markdown(text)
        Tilt["markdown"].new(context: @app) { text }.render if text
      end

      def json_output(schema)
        properties = schema_properties(schema)
        JSON.pretty_generate(properties)
      end

      def json_prettyprint(data)
        JSON.pretty_generate(data)
      end

      def schema_properties(schema_data)
        properties = {}
        if defined? schema_data.properties
          schema_data.properties.each do |key, property|
            properties[key] = property
          end
        end
        properties.merge! get_all_of_hash(schema_data)
        properties.merge! get_any_of_hash(schema_data)
        properties_hash = {}
        properties.each do |pkey, property|
          case property.type
          when "object"
            properties_hash[pkey] = {}
            items = property.items
            properties_hash[pkey] = schema_properties(items) if items.present?
            properties_hash[pkey] = schema_properties(property) if property.properties.present?
          when "array"
            properties_hash[pkey] = []
            items = property.items
            properties_hash[pkey].push schema_properties(items) if items.present?
          else
            properties_hash[pkey] = property.example.nil? ? property.type : property.example
          end
        end

        properties_hash
      end

      def schema_is_referenced?(schema)
        schema.node_context.source_location.pointer.segments[0..1] == %w[components schemas]
      end

    private

      def info
        document.info
      end

      def servers
        document.servers
      end

      def get_all_of_array(schema)
        properties = []
        schema = schema[1] if schema.is_a?(Array)
        all_of = schema["allOf"] if schema["allOf"]
        if all_of.present?
          all_of.each do |schema_nested|
            schema_nested.properties.each do |property|
              property = property[1] if property.is_a?(Array)
              properties.push property
            end
          end
        end
        properties
      end

      def get_all_of_hash(schema)
        properties = {}
        all_of = schema["allOf"] if schema["allOf"]
        if all_of.present?
          all_of.each do |schema_nested|
            schema_nested.properties.each do |key, property|
              properties[key] = property
            end
          end
        end
        properties
      end

      def get_any_of_hash(schema)
        properties = {}
        any_of = schema["anyOf"]

        if any_of.present?
          nested_schema = any_of.first
          nested_schema.properties.each do |key, property|
            properties[key] = property
          end
        end
        properties
      end

      def get_renderer(file)
        template_path = File.join(File.dirname(__FILE__), "templates/#{file}")
        template = File.read(template_path)
        ERB.new(template)
      end

      def get_operations(path)
        operations = {}
        operations["get"] = path.get if defined? path.get
        operations["put"] = path.put if defined? path.put
        operations["post"] = path.post if defined? path.post
        operations["delete"] = path.delete if defined? path.delete
        operations["patch"] = path.patch if defined? path.patch
        operations
      end

      def get_schema_name(text)
        return unless text.is_a?(String)

        # Schema dictates that it's always components['schemas']
        text.gsub(%r{#/components/schemas/}, "")
      end

      def get_schema_link(schema)
        schema_name = get_schema_name schema.node_context.source_location.to_s
        return if schema_name.nil?

        id = "schema-#{schema_name.parameterize}"
        "<a href='##{id}'>#{schema_name}</a>"
      end

      def schemas_data
        @schemas_data ||= @document.components.schemas
      end

      def format_possible_value(possible_value)
        if possible_value == ""
          "<em>empty string</em>"
        else
          possible_value
        end
      end

      def properties_for_schema(schema_name)
        schema_data = schemas_data.find { |s| s[0] == schema_name }

        properties = []

        all_of = schema_data[1]["allOf"]
        if all_of.present?
          all_of.each do |schema_nested|
            schema_nested.properties.each do |property|
              properties.push property
            end
          end
        end

        any_of = schema_data[1]["anyOf"]
        if any_of.present?
          any_of.each do |schema_nested|
            schema_nested.properties.each do |property|
              properties.push property
            end
          end
        end

        schema_data[1].properties.each do |property|
          properties.push property
        end

        properties.push ["Item", schema_data[1].items] if schema_data[1] && schema_data[1].type == "array"

        properties
      end
    end
  end
end
