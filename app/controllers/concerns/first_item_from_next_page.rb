module FirstItemFromNextPage
  extend ActiveSupport::Concern

private

  def first_item_from_next_page(collection, per_page)
    has_next_page_available = collection.size > per_page
    if has_next_page_available
      collection[per_page]
    end
  end
end
