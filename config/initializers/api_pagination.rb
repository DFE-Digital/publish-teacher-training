ApiPagination.configure do |config|
  config.page_param do |params|
    params.dig(:page, :page)
  end

  config.per_page_param do |params|
    params.dig(:page, :per_page) || Kaminari.config.default_per_page
  end
end
