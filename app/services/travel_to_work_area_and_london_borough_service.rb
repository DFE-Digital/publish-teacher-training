class TravelToWorkAreaAndLondonBoroughService
  def self.add_travel_to_work_area_and_london_borough(site:)
    new(site).add_travel_to_work_area_and_london_borough
  rescue StandardError
    false
  end

  def initialize(site)
    @site = site
  end

  def add_travel_to_work_area_and_london_borough
    ttw_area = get(:travel_to_work_area)

    if ttw_area == "London"
      london_borough = get(:london_borough)
      site.update_column("travel_to_work_area", "London")
      site.update_column("london_borough", london_borough)
    else
      site.update_column("travel_to_work_area", ttw_area)
      site.update_column("london_borough", nil)
    end

    site.save!(validate: false)
  end

private

  attr_reader :site

  def get(attribute)
    url = if attribute == :travel_to_work_area
            travel_to_work_url
          else
            london_borough_url
          end

    response = Net::HTTP.get(url)
    json = JSON.parse(response)
    name_attr = json.dig(json.keys.first, "name")
    name_attr = name_attr.gsub(/ Borough Council| City Council| Corporation/, "") if attribute == :london_borough
    name_attr
  end

  def ttw_area
    response = Net::HTTP.get(travel_to_work_url)
    json = JSON.parse(response)
    json.dig(json.keys.first, "name")
  end

  def travel_to_work_url
    url("TTW")
  end

  def london_borough_url
    url("LBO")
  end

  def url(type)
    URI("#{Settings.mapit_url}/point/4326/#{site.longitude},#{site.latitude}?type=#{type}&api_key=#{Settings.mapit_api_key}")
  end
end
