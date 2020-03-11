module TimeFormat
  # Primarily so that our incremental fetch can handle many records being
  # updated within the same second.
  #
  # The strftime format '%FT%T.%6NZ' is similar to the ISO8601 standard,
  # (equivalent to %FT%TZ) and adds micro-seconds (%6N).
  def precise_time(time)
    time.strftime("%FT%T.%6NZ")
  end

  def written_month_year(time)
    time.strftime("%B %Y")
  end

  def short_date(time)
    time.strftime("%d/%m/%Y")
  end
end
