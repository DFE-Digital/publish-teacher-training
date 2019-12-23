name "bulk_sync_to_find"
summary "Bulk sync all course to Find"
usage "bulk_sync_to_find"

run do |opts, _args, _cmd|
  opts = MCB.system_api_opts(opts)

  base_url = get_url_from_opts(opts)
  url = "#{base_url}/api/system/sync"
  token = opts[:token]

  require "httparty"

  verbose "POST #{url}"
  response = HTTParty.post(url, headers: { authorization: "Bearer #{token}" })

  puts response.code
end

def init_rails(opts)
  # Since this is an API connection, we don't want to connect to the remote
  # Rails instance, so remove <tt>webapp</tt> from the opts to
  # <tt>init_rails</tt>
  rails_opts = opts.dup
  rails_opts.delete(:webapp)
  MCB.init_rails(**rails_opts)
end

def get_url_from_opts(opts)
  # opts.fetch(:url) { ... } doesn't seem to work here
  if opts[:url]
    opts[:url]
  elsif MCB.requesting_remote_connection?(opts)
    # Connect out to get the Azure app settings if we need to.
    MCB.apiv2_base_url(opts)
  else
    "http://localhost:3001"
  end
end

def get_token_from_opts(opts)
  # opts.fetch(:token) { ... } doesn't seem to work here
  if opts[:token]
    opts[:token]
  else
    init_rails(opts)
    Settings.system_authentication_token
  end
end
