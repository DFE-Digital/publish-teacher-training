module APIDocs
  class OpenapiController < APIDocsController
    def specs
      render plain: APISpec::Public.latest.to_yaml, content_type: "text/yaml"
    end
  end
end
