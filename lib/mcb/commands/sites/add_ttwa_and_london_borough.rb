name "travel_to_work_area_or_london_borough"
summary "Batch add travel to work area or London Borough if located in London to Sites in the current cycle."
usage "travel_to_work_area [options]"
option :b, "batch_size", "batch size", argument: :optional, default: 100, transform: method(:Integer)
option :s, "sleep", "time to sleep between each request", argument: :optional, default: 0.25, transform: method(:Float)

instance_eval(&MCB.remote_connect_options)

# TODO: Shared logic in service
# model hooks to call on create/update sites postcode
# expose on V3

run do |opts, _args, _cmd|
  MCB.init_rails(opts)

  Site
  .joins(:provider)
  .where("provider.recruitment_cycle_id = ?", RecruitmentCycle.current_recruitment_cycle.id)
  .where
  .not(travel_to_work_area: nil)
  .find_each(batch_size: opts[:batch_size]) do |site|
    verbose "adding travel to work area for '#{site.provider_code}' course '#{site.course_code} course '#{site.code}'"

    url = URI("https://mapit.mysociety.org/point/4326/#{site.longitude},#{site.latitude}?type=TTW,LBO&api_key=#{Settings.mapit_api_key}")
    response = Net::HTTP.get(url)
    json = JSON.parse(response)

    ttw_area = json.dig(json.keys.first, "name")

    site.update!(travel_to_work_area: ttw_area)

    if ttw_area == "London"
      london_borough = json.dig(json.keys.second, "name")
      site.update!(london_borough: london_borough)
    end

    sleep(opts[:sleep])
  end
end
