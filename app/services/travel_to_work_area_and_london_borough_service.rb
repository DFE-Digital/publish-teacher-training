class TravelToWorkAreaAndLondonBoroughService
  include ServicePattern

  def initialize(site:)
    @site = site
  end

  def call
    ttw_area = get(:travel_to_work_area)

    if ttw_area == "London"
      london_borough = get(:london_borough)

      if london_borough
        site.travel_to_work_area = "London"
        site.london_borough = london_borough
        site.save!(validate: false)
      end
    elsif ttw_area
      site.travel_to_work_area = ttw_area
      site.london_borough = nil
      site.save!(validate: false)
    else
      false
    end
  end

private

  attr_reader :site

  def get(attribute)
    url = if attribute == :travel_to_work_area
            travel_to_work_url
          else
            london_borough_url
          end

    response = Net::HTTP.get_response(url)

    if response.code == "200"
      json = JSON.parse(response.body)
      name_attr = json.dig(json.keys.first, "name")
      name_attr = name_attr&.gsub(/ Borough Council| City Council| Corporation/, "") if attribute == :london_borough
      name_attr
    end
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
