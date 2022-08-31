Time::DATE_FORMATS[:govuk_date] = "%-d %B %Y"
Time::DATE_FORMATS[:govuk_date_short_month] = "%-d %b %Y"
Date::DATE_FORMATS[:govuk_date] = "%-d %B %Y"

Time::DATE_FORMATS[:month_and_year] = "%B %Y"
Date::DATE_FORMATS[:month_and_year] = "%B %Y"

Time::DATE_FORMATS[:short_month_and_year] = "%b %Y"
Date::DATE_FORMATS[:short_month_and_year] = "%b %Y"

Time::DATE_FORMATS[:day_and_month] = "%d %B"
Date::DATE_FORMATS[:day_and_month] = "%d %B"

Time::DATE_FORMATS[:govuk_date_and_time] = lambda do |time|
  format = if time.min.zero?
             "%l%P on %e %B %Y"
           else
             "%l:%M%P on %e %B %Y"
           end

  time.strftime(format).squish
end

Time::DATE_FORMATS[:govuk_time] = lambda do |time|
  format = if time.min.zero?
             "%l%P"
           else
             "%l:%M%P"
           end

  time.strftime(format).squish
end
