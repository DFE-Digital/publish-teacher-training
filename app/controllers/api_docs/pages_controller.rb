module APIDocs
  class PagesController < APIDocsController
    def home
      render_content_page :home
    end

    def help
      render_content_page :help
    end

    def release_notes
      render_content_page :release_notes
    end

    def specs
      render_content_page :specs
    end

  private

    def render_content_page(page_name)
      @converted_markdown = Govuk::MarkdownRenderer.render(
        File.read("app/views/api_docs/pages/#{page_name}.md"),
      )
      @page_name = page_name
      render "rendered_markdown_template"
    end
  end
end
