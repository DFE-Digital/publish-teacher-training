ApiPagination.configure do |config|
  config.page_param do |params|
    params.dig(:page, :page)
  end

  config.per_page_param do |params|
    params.dig(:page, :per_page) || 10
  end
end
