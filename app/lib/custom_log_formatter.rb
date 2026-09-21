# frozen_string_literal: true

class CustomLogFormatter < SemanticLogger::Formatters::Json
  REDACTED = "[REDACTED]"

  def call(log, logger)
    super

    format_job_data
    format_exception
    format_json_message_context
    format_backtrace
    remove_post_params
    redact_solid_queue_arguments

    format_payload_with_named_tags

    hash.to_json
  end

private

  def format_payload_with_named_tags
    hash[:payload] ||= {}
    hash[:payload].merge!(log.named_tags)
    log.named_tags.clear
  end

  def format_job_data
    hash[:job_id] = RequestStore.store[:job_id] if RequestStore.store[:job_id].present?
    hash[:job_queue] = RequestStore.store[:job_queue] if RequestStore.store[:job_queue].present?
  end

  def format_exception
    exception_message = hash.dig(:exception, :message)
    return if exception_message.nil?

    hash[:message] = "Exception occured: #{exception_message}"
  end

  def format_json_message_context
    if hash[:message].present?
      context = JSON.parse(hash[:message])["context"]
      hash[:sidekiq_job_context] = hash[:message]
      hash[:message] = context
    end
  rescue JSON::ParserError
    nil
  end

  def format_backtrace
    return unless hash[:message]&.start_with?("/")

    message_lines = hash[:message].split("\n")
    return unless message_lines.all? { |line| line.start_with?("/") }

    hash[:backtrace] = hash[:message]
    hash[:message] = "Exception occured: #{message_lines.first}"
  end

  def remove_post_params
    return unless method_is_post_or_put_or_patch? && hash.dig(:payload, :params).present?

    hash[:payload][:params].clear
  end

  def redact_solid_queue_arguments
    return if hash.dig(:payload, :adapter).blank? || hash.dig(:payload, :arguments).blank?
    return unless hash.dig(:payload, :adapter).include?("SolidQueue")

    hash[:payload][:arguments] = filter_job_arguments(hash[:payload][:arguments])
  end

  def filter_job_arguments(value)
    case value
    when Array
      value.map { |item| filter_job_arguments(item) }
    when Hash
      job_argument_filter.filter(value)
    when String
      filter_json_job_arguments(value)
    else
      value
    end
  end

  # rails_semantic_logger stores Active Job args as JSON.pretty_generate(...),
  # not a Ruby Array.
  def filter_json_job_arguments(value)
    filtered = filter_job_arguments(JSON.parse(value))
    JSON.pretty_generate(filtered)
  rescue JSON::ParserError
    value
  end

  def job_argument_filter
    @job_argument_filter ||= ActiveSupport::ParameterFilter.new(
      Rails.application.config.filter_parameters + %i[email_address code data body hidden_data headers],
      mask: REDACTED,
    )
  end

  def method_is_post_or_put_or_patch?
    hash.dig(:payload, :method).in?(%w[PUT POST PATCH])
  end
end
