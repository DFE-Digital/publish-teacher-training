class Find::Courses::ResultsPageTitle::View < ViewComponent::Base
  def initialize(courses_count:, address:)
    @courses_count = courses_count
    @address = address

    super
  end

  def content
    if @address.formatted_address.present?
      t(
        ".page_title_with_location",
        location: @address.short_address,
        count: @courses_count,
        formatted_count:,
      )
    else
      t(
        ".page_title_without_location",
        count: @courses_count,
        formatted_count:,
      )
    end
  end

  def formatted_count
    number_with_delimiter(@courses_count)
  end
end
