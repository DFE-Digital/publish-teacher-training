class EditCourseOptions
  def initialize(course)
    @course = course
  end

  def entry_requirements
    Course::ENTRY_REQUIREMENT_OPTIONS
      .reject { |a| a.include? %i[not_set not_required] }
      .map do |choice|
      option = { value: choice }

      case choice
      when :must_have_qualification_at_application_time
        option[:text] = '1. Must have (least flexible)'
        option[:help] = 'UCAS will block applications from candidates who haven’t gained their GCSE yet or who need to take an equivalency test.'
      when :expect_to_achieve_before_training_begins
        option[:text] = '2: Taking'
        option[:help] = 'You will consider candidates with a pending GCSE. But UCAS will block applications from someone who needs to take an equivalency test.'
      when :equivalence_test
        option[:text] = '3: Equivalence test'
        option[:help] = 'You will consider candidates who need to take an equivalency test as well as those with a pending GCSE.'
      end

      option
    end
  end
end
