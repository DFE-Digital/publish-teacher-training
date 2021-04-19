class TravelToWorkAreaAndLondonBoroughService
  include ServicePattern

  def initialize(site:)
    @site = site
  end

  def call
    ttw_area = get(:travel_to_work_area)

    if ttw_area == "London"
      update_london_borough
    elsif ttw_area
      update_ttw_area(ttw_area)
    else
      false
    end
  end

private

  attr_reader :site

  def update_london_borough
    london_borough = get(:london_borough)
    return false unless london_borough

    if london_borough
      site.travel_to_work_area = "London"
      site.london_borough = london_borough
      site.save!(validate: false)
    end
  end

  def update_ttw_area(ttw_area)
    site.travel_to_work_area = ttw_area
    site.london_borough = nil
    site.save!(validate: false)
  end

  def get(attribute)
    response = Net::HTTP.get_response(url_for(attribute))

    if response.is_a?(Net::HTTPSuccess)
      json = JSON.parse(response.body)
      name_attr = json.dig(json.keys.first, "name")
      name_attr = name_attr&.gsub(/ Borough Council| City Council| Corporation/, "") if attribute == :london_borough
      name_attr
    else
      generate_sentry_error(response.code, attribute)
      false
    end
  end

  def generate_sentry_error(response_code, attribute)
    message = "Mapit API has returned status code #{response_code} for Site id #{site.id} whilst trying to obtain #{attribute}"
    Sentry.capture_message(message)
  end

  def url_for(attribute)
    if attribute == :travel_to_work_area
      travel_to_work_query
    else
      london_borough_query
    end
  end

  def travel_to_work_query
    mapit_query("TTW")
  end

  def london_borough_query
    mapit_query("LBO")
  end

  def mapit_query(type)
    URI("#{Settings.mapit_url}/point/4326/#{site.longitude},#{site.latitude}?type=#{type}&api_key=#{Settings.mapit_api_key}")
  end
end
