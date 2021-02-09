class TravelToWorkAreaAndLondonBoroughService
  def self.add_travel_to_work_area_and_london_borough(site:)
    url = URI("https://mapit.mysociety.org/point/4326/#{site.longitude},#{site.latitude}?type=TTW,LBO&api_key=#{Settings.mapit_api_key}")
    response = Net::HTTP.get(url)
    json = JSON.parse(response)

    ttw_area = json.dig(json.keys.first, "name")

    site.update!(travel_to_work_area: ttw_area)

    if ttw_area == "London"
      london_borough = json.dig(json.keys.second, "name")
      site.update!(london_borough: london_borough)
    end
  rescue StandardError
    false
  end
end
