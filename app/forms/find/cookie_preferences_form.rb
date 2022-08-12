module Find
  class CookiePreferencesForm
    include ActiveModel::Model

    attr_accessor :consent, :cookies, :cookie_name, :expiry_date

    validates :consent, presence: true, inclusion: { in: %w[accepted rejected] }

    def initialize(cookies, params = {})
      @cookies = cookies
      @cookie_name = Settings.cookies.consent.name
      @expiry_date = Settings.cookies.consent.expire_after_days.days.from_now
      @consent = params[:consent] || cookies[cookie_name]
    end

    def save
      if valid?
        cookies[cookie_name] = { value: consent, expires: expiry_date }
      end
    end
  end
end
