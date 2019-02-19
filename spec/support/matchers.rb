RSpec::Matchers.define :be_findable do
  match do |actual|
    SiteStatus.findable.include?(actual)
  end
end

RSpec::Matchers.define :be_open_for_applications do
  match do |actual|
    SiteStatus.open_for_applications.include?(actual)
  end
end

RSpec::Matchers.define :have_vacancies do
  match do |actual|
    SiteStatus.with_vacancies.include?(actual)
  end
end
