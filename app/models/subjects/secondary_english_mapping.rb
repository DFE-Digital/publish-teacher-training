# TODO: remove this bonkers logic once course mapping is done by one app!
# The user need for this is unclear
#
# Does the subject list mention english, and it's mentioned in the title (or it's the only subject we know for this course)?
module Subjects
  class SecondaryEnglishMapping
    def initialize(course_title)
      @course_title = course_title
    end

    def applicable_to?(ucas_subjects)
      (ucas_subjects & ucas_english).any? &&
        @course_title.index("english") != nil
    end

    def to_s
      "English"
    end

  private

    def ucas_english
      ["english",
       "english language",
       "english literature"]
    end
  end
end
