# frozen_string_literal: true

xml.instruct!
xml.urlset "xmlns" => "http://www.google.com/schemas/sitemap/0.9", "xmlns:xhtml" => "http://www.w3.org/1999/xhtml" do
  xml.url do
    xml.loc find_root_url
  end

  xml.url do
    xml.loc find_results_url
  end

  @courses.each do |provider_code, course_code, changed_at|
    xml.url do
      xml.loc find_course_url(provider_code, course_code)
      xml.lastmod changed_at.to_date.strftime("%Y-%m-%d")
    end
  end
end
