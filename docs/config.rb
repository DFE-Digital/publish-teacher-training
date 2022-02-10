require "govuk_tech_docs"
require "lib/govuk_tech_docs/open_api/extension"

GovukTechDocs.configure(self)

activate :open_api

configure :build do
  activate :relative_assets
end
