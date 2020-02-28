module APIDocs
  class ReferenceController < APIDocsController
    def reference
      version = params[:version]

      @api_reference = if version.present?
                         APIReference.public(version: version)
                       else
                         APIReference.latest
                       end
    end
  end
end
