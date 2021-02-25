name "add travel to work data"
summary "Batch add travel to work area or London Borough if located in London to Sites in the current cycle."
usage "add_travel_to_work_data [options]"
option :b, "batch_size", "batch size", argument: :optional, default: 100, transform: method(:Integer)
option :s, "sleep", "time to sleep between each request", argument: :optional, default: 0.25, transform: method(:Float)

instance_eval(&MCB.remote_connect_options)

run do |opts, _args, _cmd|
  MCB.init_rails(opts)

  RecruitmentCycle
    .current
    .sites
    .where
    .not(latitude: nil, longitude: nil)
    .find_each(batch_size: opts[:batch_size]) { |site|
      verbose "adding travel to work area for site id '#{site.id}' site code '#{site.code}'"
      success = TravelToWorkAreaAndLondonBoroughService.call(site: site)
      verbose "Success? #{success}"
      sleep(opts[:sleep])
    }
end
