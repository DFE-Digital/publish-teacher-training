Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "http://www.publish.test:3000"
    resource "*", headers: :any, methods: %i[get post]
  end
end
