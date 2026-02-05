# frozen_string_literal: true

require "govuk_tech_docs"
require "lib/govuk_tech_docs/open_api/extension"

::GovukTechDocs::TableOfContents::Helpers.module_eval do
  def select_top_level_html_files(resources)
    prefix = config[:http_prefix]
    home_url = prefix.end_with?("/") ? prefix : "#{prefix}/"

    resources
      .select { |r| r.path.end_with?(".html") && (r.parent.nil? || r.parent.url == home_url) }
  end
end

GovukTechDocs.configure(self)

activate :open_api

configure :build do
  set :http_prefix, "/docs/"
end
