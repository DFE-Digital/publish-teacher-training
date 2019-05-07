name 'create'
summary 'Create a new site in db'
usage 'create <provider_code>'
param :provider_code

# module MCB
  class SiteShow
    def initialize(site)
      @site = site
    end

    def to_h
      {
        "Name" => @site.location_name,
        "Building and street" => @site.address1,
        "Building and street 2" => @site.address2,
        "Town or city" => @site.address3,
        "County" => @site.address4,
        "Postcode" => @site.postcode,
        "Region code" => @site.region_code,
        "Code" => @site.code,
        "Provider" => @site.provider.provider_code,
      }
    end
  end
# end

def confirm_creation_of(site)
  puts "\nAbout to create the following site:"
  puts Terminal::Table.new rows: SiteShow.new(site).to_h

  print "Continue? "

  response = $stdin.readline
  response.match %r{^y(es?)?}i
end

run do |opts, args, _cmd|
  MCB.init_rails(opts)

  Provider.connection.transaction do
    args.each do |provider_code|
      provider = Provider.find_by!(provider_code: provider_code)
      site = Site.new(
        provider: provider,
        location_name: 'Hangleton Primary School',
        address1: 'Dale View', # Building and street
        address2: '', # street 2
        address3: 'Hove', # Town or city
        address4: 'East Sussex', # county
        postcode: 'BN3 8LF',
        region_code: :south_east,
        code: 'H',
      )

      if confirm_creation_of(site)
        if site.valid?
          puts "Saving the site"
          site.save!
        else
          puts "Site isn't valid:"
          site.full_error_messages.each { |error| puts " - #{error}" }
        end
      else
        puts "Aborting"
      end
    end
  end
end
