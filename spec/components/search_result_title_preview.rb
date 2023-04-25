# frozen_string_literal: true

class SearchResultTitlePreview < ViewComponent::Preview
  def with_many_results = render_component(10_000)

  def with_few_results = render_component

  def with_1_result = render_component(1)

  def with_no_results = render_component(0)

  def with_custom_caption = render_component(10_000, 'Some custom caption text')

  private

  def query = 'test'
  def return_path = '/test'
  def results_limit = 15
  def search_resource = 'model'

  def render_component(results_count = 10, caption_text = nil)
    render(
      SearchResultTitleComponent.new(
        query:,
        results_limit:,
        results_count:,
        return_path:,
        search_resource:,
        caption_text:
      )
    )
  end
end
