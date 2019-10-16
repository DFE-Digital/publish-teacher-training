# Reference data that gets created for every test as a matter of convenience.
#
# There is some data that we can assume will always be in the db, and, where
# it's cheap enough to do so, we can create by default so that it's always
# there. Any such reference data should be find_or_create-able so that specs
# can easily re-use it, and should also be disable-able for tests that don't
# want it.

RSpec.configure do |config|
  # It will be pretty standard to always have a recruitment cycle in the db,
  # and adding it here is much cheaper and less noisy than adding it to 90% of
  # the tests.
  #
  # Disable with the tag: no_default_recycle: true
  # Retrieve with: find_or_create(:recruitment_cycle)
  config.before(:each) do |example|
    unless example.metadata[:no_default_recycle] == true
      find_or_create :recruitment_cycle
    end
  end

  # It's standard to have subjects in the DB, so create them by default, and use
  # the tag "without_subjects: true" to make sure the subjects table is empty
  # for tests that need it.
  config.before(:all) do
    SubjectCreatorService.new.execute
  end

  config.before(:each, without_subjects: true) do
    Subject.delete_all
  end
end
