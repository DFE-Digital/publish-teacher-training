require 'mcb_helper'

describe 'mcb providers list' do
  def list(*arguments)
    stderr = nil
    output = with_stubbed_stdout(stdin: "", stderr: stderr) do
      $mcb.run %W[courses list] + arguments
    end
    { stdout: output, stderr: stderr }
  end

  let(:current_cycle) { RecruitmentCycle.current_recruitment_cycle }
  let(:additional_cycle) { find_or_create(:recruitment_cycle, year: '2018') }

  context 'when recruitment cycle is unspecified' do
    let(:provider1) { create(:provider, recruitment_cycle: current_cycle) }
    let(:provider2) { create(:provider, recruitment_cycle: current_cycle) }
    let(:provider3) { create(:provider, recruitment_cycle: additional_cycle) }

    let(:course1) { create(:course, provider: provider1) }
    let(:course2) { create(:course, provider: provider2) }
    let(:course3) { create(:course, provider: provider3) }

    it 'lists all courses for the default recruitment cycle' do
      course1
      course2
      course3

      command_output = list[:stdout]

      expect(command_output).to include(course1.course_code)
      expect(command_output).to include(course1.name)

      expect(command_output).to include(course2.course_code)
      expect(command_output).to include(course2.name)

      expect(command_output).not_to include(course3.course_code)
      expect(command_output).not_to include(course3.name)
    end

    context 'when course is specified' do
      it 'displays the provider information' do
        course1
        course2

        command_output = list(course1.course_code)[:stdout]

        expect(command_output).to include(course1.course_code)
        expect(command_output).to include(course1.name)

        expect(command_output).not_to include(course2.course_code)
        expect(command_output).not_to include(course2.name)
      end

      it 'displays multiple specified courses' do
        course1
        course2

        command_output = list(course1.course_code, course2.course_code)[:stdout]

        expect(command_output).to include(course1.course_code)
        expect(command_output).to include(course1.name)

        expect(command_output).to include(course2.course_code)
        expect(command_output).to include(course2.name)
      end

      it 'is case insensitive' do
        course1
        course2

        command_output = list(course2.course_code.downcase)[:stdout]
        expect(command_output).to include(course2.course_code)
      end
    end

    context 'when provider is unspecified' do
      it 'displays information about courses for the current recruitment cycle' do
        course1
        course2

        command_output = list[:stdout]

        expect(command_output).to include(course1.course_code)
        expect(command_output).to include(course1.name)

        expect(command_output).to include(course2.course_code)
        expect(command_output).to include(course2.name)
      end
    end
  end

  context 'when recruitment cycle is specified' do
    let(:provider1) { create(:provider, recruitment_cycle: current_cycle) }
    let(:provider2) { create(:provider, recruitment_cycle: additional_cycle) }

    let(:course1) { create(:course, provider: provider1) }
    let(:course2) { create(:course, provider: provider2) }

    it 'displays information about courses for the specified recruitment cycle' do
      course1
      course2

      command_output = list("-r", additional_cycle.year)[:stdout]

      expect(command_output).to include(course2.course_code)
      expect(command_output).to include(course2.name)

      expect(command_output).not_to include(course1.course_code)
      expect(command_output).not_to include(course1.name)
    end
  end
end
