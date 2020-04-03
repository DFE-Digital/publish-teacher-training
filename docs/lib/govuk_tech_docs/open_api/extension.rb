require "openapi3_parser"
require "uri"
require_relative "renderer"

module GovukTechDocs
  module OpenApi
    class Extension < Middleman::Extension
      expose_to_application api: :api

      def initialize(app, options_hash = {}, &block)
        super

        @app = app
        @config = @app.config[:tech_docs]

        # If no api path then just return.
        if api_path.empty?
          @api_parser = false
          return
        end

        if uri?(api_path)
          @api_parser = true
          @document = Openapi3Parser.load_url(api_path)
        elsif File.exist?(api_path)
          # Load api file and set existence flag.
          @api_parser = true
          @document = Openapi3Parser.load_file(api_path)
        else
          @api_parser = false
          raise "Unable to load api path from tech-docs.yml"
        end
        @render = Renderer.new(@app, @document)
      end

      def uri?(string)
        uri = URI.parse(string)
        %w(http https).include?(uri.scheme)
      rescue URI::BadURIError
        false
      rescue URI::InvalidURIError
        false
      end

      def api(text)
        if @api_parser == true

          keywords = {
            "api&gt;" => "default",
            "api_schema&gt;" => "schema",
          }

          regexp = keywords.map { |k, _| Regexp.escape(k) }.join("|")

          md = text.match(/^<p>(#{regexp})/)

          if md
            key = md.captures[0]
            type = keywords[key]

            text.gsub!(/#{Regexp.escape(key)}\s+?/, "")

            # Strip paragraph tags from text
            text = text.gsub(/<\/?[^>]*>/, "")
            text = text.strip

            if text == "api&gt;"
              @render.api_full
            elsif type == "default"
              output = @render.path(text)
              # Render any schemas referenced in the above path
              output += @render.schemas_from_path(text)
              output
            else
              @render.schema(text)
            end
          else
            return text
          end
        else
          text
        end
      end

    private

      def api_path
        @config["open_api_path"].to_s
      end
    end
  end
end

::Middleman::Extensions.register(:open_api, GovukTechDocs::OpenApi::Extension)
