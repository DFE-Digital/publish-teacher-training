SitemapGenerator::Sitemap.default_host = Settings.publish_url

SitemapGenerator::Sitemap.create do
  Course.findable.find_each do |course|
    add "/course/#{course.provider.provider_code}/#{course.course_code}", lastmod: course.changed_at
  end
end
