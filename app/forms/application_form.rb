# frozen_string_literal: true

class ApplicationForm
  include ActiveModel::Model

  def t(key, options = {})
    I18n.t(key, options.merge(scope: [:forms, *options[:scope]]))
  end
end
