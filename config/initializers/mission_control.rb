# frozen_string_literal: true

# Mission Control only redacts top-level hash keys (not nested / positional args).
# Reuse filter_parameters (partial match list) plus Active Job argument names we use.
Rails.application.config.after_initialize do
  from_filter_parameters = Rails.application.config.filter_parameters.filter_map do |param|
    case param
    when String, Symbol then param.to_s
    end
  end

  keys = (from_filter_parameters + %w[email_address code data body hidden_data headers]).uniq
  MissionControl::Jobs.filter_arguments = keys
  Rails.application.config.mission_control.jobs.filter_arguments = keys
end
