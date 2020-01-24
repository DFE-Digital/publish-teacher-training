# rubocop:disable Style/ClassVars
class TestDataCache
  #  A helper class for pre-creating test data with FactoryBot factories
  #  and maintaining a cache of these objects to avoid the performance problems
  #  of repeatedly asking FactoryBot to create trees of objects.
  #
  #  Refs: https://evilmartians.com/chronicles/testprof-2-factory-therapy-for-your-ruby-tests-rspec-minitest
  #
  # The test data and can be accessed as follows:
  #
  # TestDataCache.get(:course, :primary, :unpublished)
  #
  # Note that a course with the requested traits needs to be pre-defined in this class.
  # It does not matter what order the traits are when passed as arguments.

  class << self
    def get(name, *traits)
      case name
      when :course
        if @@courses == nil
          # cache not populated, fall back to factory (while we migrate all our tests)
          FactoryBot.create(name, *traits)
        else
          @@courses[traits.sort] || raise_trait_error(:course, traits)
        end
      else
        raise "Unknown model type #{name}: - You need to add this to TestSetup or use a standard FactoryBot factory."
      end
    end

    def create_and_cache_test_records
      @@courses = @@course_factories.transform_values(&:call)
    end

    def clear
      @@courses = nil
    end

  private

    @@courses = nil
    @@course_factories = {
        %i[primary unpublished] => -> do
          FactoryBot.find_or_create(:course, :primary, :unpublished)
        end,
    }

    def raise_trait_error(factory_type, traits)
      raise(
        <<~ERR_MSG,
          No predefined #{factory_type} for these traits: #{traits}.
          Either add it to test_setup.rb or if it's used frequently, just create
          a FactoryBot factory instance.
        ERR_MSG
      )
    end
  end
end
# rubocop:enable Style/ClassVars
