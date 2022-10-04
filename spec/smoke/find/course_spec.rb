# frozen_string_literal: true

require "nokogiri"
require "spec_helper_smoke"

class HtmlParserIncluded < HTTParty::Parser
  def html
    Nokogiri::HTML(body)
  end
end

class FindResultsPage
  include HTTParty
  parser HtmlParserIncluded

  base_uri Settings.search_ui.base_url

  Course = Struct.new(:url)

  def self.call
    new.courses
  end

  def response
    @response ||= self.class.get("/results?age_group=primary&l=2&subject_codes%5B%5D=00").parsed_response
  end

  def courses
    response.css(".app-search-results .app-search-results__item .app-search-result__item-title").map do |course|
      Course.new(course.css('a[data-qa="course__link"]').first["href"])
    end
  end
end

describe "Find Service Smoke Tests", :aggregate_failures, smoke: true, skip: true do
  let(:base_url) { FindResultsPage.base_uri }
  let(:courses) { FindResultsPage.call }
  let(:url) { "#{base_url}/#{courses.first.url}" }

  subject(:response) { HTTParty.get(url) }

  describe "Search and view a course" do
    it "returns HTTP success" do
      expect(response.code).to eq(200)
    end
  end
end
