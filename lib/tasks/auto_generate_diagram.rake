# See: https://github.com/voormedia/rails-erd/blob/master/lib/tasks/auto_generate_diagram.rake
# This file ensures that database diagram is re-generated with every database change following db:migrate
if Rails.env.development?
  RailsERD.load_tasks
end
