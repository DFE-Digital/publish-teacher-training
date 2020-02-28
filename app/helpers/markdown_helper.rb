module MarkdownHelper
  def markdown_to_html(markdown)
    # rubocop: disable Rails/OutputSafety
    Govuk::MarkdownRenderer.render(markdown.to_s).html_safe
    # rubocop: enable Rails/OutputSafety
  end
end
