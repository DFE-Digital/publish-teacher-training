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
    @@cache_populated = false
    @@courses = nil

    def get(name, *traits)
      case name
      when :course
        if @@cache_populated
          @@courses[traits.sort] || raise_trait_error(:course, traits)
        else
          # fall back to uncached factory (while we migrate all our tests)
          create_uncached_factory(name, traits)
        end
      else
        raise_model_error(name, traits)
      end
    end

    def create_and_cache_test_records
      @@courses = course_factories.transform_values(&:call)
      @@cache_populated = true
    end

    def clear
      @@courses = nil
      @@cache_populated = false
    end

  private

    def course_factories
      {
          %i[primary unpublished] => -> do
            FactoryBot.create(:course, :primary, :unpublished)
          end,
          %i[resulting_in_qts] => -> do
            FactoryBot.create(:course, :resulting_in_qts)
          end,
          %i[resulting_in_pgce_with_qts] => -> do
            FactoryBot.create(:course, :resulting_in_pgce_with_qts)
          end,
          %i[resulting_in_pgde_with_qts] => -> do
            FactoryBot.create(:course, :resulting_in_pgde_with_qts)
          end,
          %i[resulting_in_pgce] => -> do
            FactoryBot.create(:course, :resulting_in_pgce)
          end,
          %i[resulting_in_pgde] => -> do
            FactoryBot.create(:course, :resulting_in_pgde)
          end,
      }
    end

    def create_uncached_factory(name, traits)
      if course_factories.key?(traits.sort)
        course_factories[traits.sort].call
      else
        raise_model_error(name, traits)
      end
    end

    def raise_model_error(name, traits)
      raise(
        <<~ERR_MSG,
          Unknown model type '#{name}' for traits '#{traits}'.
          You need to add '#{name}' to TestSetup or use a standard FactoryBot factory.
        ERR_MSG
      )
    end

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
