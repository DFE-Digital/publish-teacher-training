# frozen_string_literal: true

module APIKeySecret
  PREFIX = "ptt_"
  FORMAT = /#{PREFIX}\h{64}/

  def self.present_in?(text)
    CGI.unescape(text.b.gsub(/%(?:25)+/, "%")).match?(FORMAT)
  end

  def self.mask(value, with: ActiveSupport::ParameterFilter::FILTERED)
    value.replace(with) if value.is_a?(String) && present_in?(value)
  end
end
