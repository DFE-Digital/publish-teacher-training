name 'delete'
summary 'delete sites in db'
usage 'delete [options] <site code>'
param :site_code

run do |opts, args, _cmd|
  cli = MCB::BaseCLI.new
  site_code = args[:site_code]
  site = MCB.get_recruitment_cycle(opts).sites.find_by(code: site_code)

  if site.nil?
    puts "The site #{site_code} does not exist"
  elsif cli.confirm_deletion?("site #{site_code}")
    site.destroy
    if site.destroyed?
      puts "\nSite deleted"
    else
      puts "\nFailed to delete site"
    end
  else
    puts "\nSite not deleted"
  end
end
