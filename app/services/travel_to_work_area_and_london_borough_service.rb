class TravelToWorkAreaAndLondonBoroughService
  def self.add_travel_to_work_area_and_london_borough(site:)
    url = URI("#{Settings.mapit_url}/point/4326/#{site.longitude},#{site.latitude}?type=TTW,LBO&api_key=#{Settings.mapit_api_key}")
    response = Net::HTTP.get(url)
    json = JSON.parse(response)

    ttw_area = json.dig(json.keys.first, "name")

    if ttw_area == "London"
      london_borough = json.dig(json.keys.second, "name")
    else
      london_borough = nil
    end

    site.update_column('travel_to_work_area', ttw_area)
    site.update_column('london_borough', london_borough)
    site.save!(validate: false)
  rescue StandardError
    false
  end
end
