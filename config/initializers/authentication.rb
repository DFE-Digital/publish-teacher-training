if Rails.env.development? || Rails.env.test?
  AUTHENTICATION = { 'bat' => 'beta' }.freeze
elsif Rails.env.production? && ENV['AUTHENTICATION_CREDENTIALS'].present?
  AUTHENTICATION = JSON.parse(ENV['AUTHENTICATION_CREDENTIALS'])
else
  raise "In production mode, AUTHENTICATION_CREDENTIALS needs to be set with JSON key-value pairs with email and password"
end
