# frozen_string_literal: true

module PublishHelper
  def old_publish_link_for(path)
    "#{Settings.publish_url}#{path.sub(/\/publish\//, '/')}"
  end
end
