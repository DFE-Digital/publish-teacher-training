# Wrapper for our API Specs
#
# This concern contains methods to operate on our API specs, primarily defined
# as OpenAPI specs.
module APISpec
  extend ActiveSupport::Concern

  class_methods do
    def latest
      version(latest_version_number)
    end

    def version(version)
      self.new(openapi_file_path % { version: version })
    end
  end

  attr_reader :openapi_spec_file

  def initialize(path)
    @openapi_spec_file = path
  end

  def to_openapi
    Openapi3Parser.load(to_yaml)
  end

  def to_yaml
    @to_yaml ||= JSON.parse(File.read(@openapi_spec_file)).to_yaml
  end
end
