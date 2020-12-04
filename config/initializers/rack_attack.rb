if Settings.throttled.enabled
  Rack::Attack.throttle("global",
                        limit: Settings.throttled.global.limit,
                        period: Settings.throttled.global.period, &:path)
end
