# frozen_string_literal: true

module Paginator
  class ViewPreview < ViewComponent::Preview
    def on_first_page_of_many
      render(Paginator::View.new(scope: scope))
    end

    def on_second_page_of_many
      render(Paginator::View.new(scope: scope(current_page: 2)))
    end

  private

    def scope(current_page: 1, total_count: 29, page_size: 25)
      Struct.new(
        :relation,
        :total_count,
        :limit_value,
        :current_page,
        :total_pages,
      ).new(
        Provider.all.page(1),
        total_count,
        page_size,
        current_page,
        (total_count.to_f / page_size).ceil,
      )
    end
  end
end
