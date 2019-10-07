summary "Withdraw courses for a pre determined list of providers"
usage "withdraw_courses"

run do |opts, args, _cmd|
  MCB.init_rails(opts)
  providers = RecruitmentCycle.find_by(year: '2020').providers.where(provider_code: ['1XN',
                                                                      '1KM',
                                                                      '156',
                                                                      '1PG',
                                                                      '2BG',
                                                                      '1OZ',
                                                                      '2JS',
                                                                      '1SC',
                                                                      '169',
                                                                      '19W',
                                                                      '1DF',
                                                                      '2LQ',
                                                                      '2LL'])

  providers.each do |provider|
    provider.courses.each do |course|
      course.withdraw
    end
  end
end
