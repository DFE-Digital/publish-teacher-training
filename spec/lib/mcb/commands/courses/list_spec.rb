require "mcb_helper"

describe "mcb courses list" do
  def execute_list(arguments: [], input: [])
    with_stubbed_stdout(stdin: input.join("\n")) do
      $mcb.run(["courses", "list", *arguments])
    end
  end

  let(:current_cycle) { RecruitmentCycle.current_recruitment_cycle }
  let(:additional_cycle) { find_or_create(:recruitment_cycle, :next) }

  context "when recruitment cycle is unspecified" do
    let(:provider1) { create(:provider, recruitment_cycle: current_cycle) }
    let(:provider2) { create(:provider, recruitment_cycle: current_cycle) }
    let(:provider3) { create(:provider, recruitment_cycle: additional_cycle) }

    # Explicitly setting the course names, Course Factory isn't random enough
    let(:course_present) { create(:course, provider: provider1, name: "English") }
    let(:course_present2) { create(:course, provider: provider2, name: "Maths") }
    let(:course_not_present) { create(:course, provider: provider3, name: "Swedish") }

    it "lists all courses for the default recruitment cycle" do
      course_present
      course_present2
      course_not_present

      command_output = execute_list[:stdout]

      expect(command_output).to include(course_present.course_code)
      expect(command_output).to include(course_present.name)

      expect(command_output).to include(course_present2.course_code)
      expect(command_output).to include(course_present2.name)

      expect(command_output).not_to include(course_not_present.course_code)
      expect(command_output).not_to include(course_not_present.name)
    end

    context "when course is specified" do
      it "displays the provider information" do
        course_present
        course_present2

        command_output = execute_list(arguments: [course_present.course_code])[:stdout]

        expect(command_output).to include(course_present.course_code)
        expect(command_output).to include(course_present.name)

        expect(command_output).not_to include(course_present2.course_code)
        expect(command_output).not_to include(course_present2.name)
      end

      it "displays multiple specified courses" do
        course_present
        course_present2

        command_output = execute_list(arguments: [course_present.course_code, course_present2.course_code])[:stdout]

        expect(command_output).to include(course_present.course_code)
        expect(command_output).to include(course_present.name)

        expect(command_output).to include(course_present2.course_code)
        expect(command_output).to include(course_present2.name)
      end

      it "is case insensitive" do
        course_present
        course_present2

        command_output = execute_list(arguments: [course_present2.course_code.downcase])[:stdout]
        expect(command_output).to include(course_present2.course_code)
      end
    end

    context "when provider is unspecified" do
      it "displays information about courses for the current recruitment cycle" do
        course_present
        course_present2

        command_output = execute_list[:stdout]

        expect(command_output).to include(course_present.course_code)
        expect(command_output).to include(course_present.name)

        expect(command_output).to include(course_present2.course_code)
        expect(command_output).to include(course_present2.name)
      end
    end
  end

  context "when recruitment cycle is specified" do
    let(:provider1) { create(:provider, recruitment_cycle: current_cycle) }
    let(:provider2) { create(:provider, recruitment_cycle: additional_cycle) }

    let(:course1) { create(:course, name: "C1", provider: provider1) }
    let(:course2) { create(:course, name: "C2", provider: provider2) }

    it "displays information about courses for the specified recruitment cycle" do
      course1
      course2

      command_output = execute_list(arguments: ["-r", additional_cycle.year])[:stdout]

      expect(command_output)
        .to have_cell_containing(course2.course_code).at_column(2)
      expect(command_output)
        .to have_cell_containing(course2.name).at_column(3)

      expect(command_output)
        .not_to have_cell_containing(course1.course_code).at_column(2)
      expect(command_output)
        .not_to have_cell_containing(course1.name).at_column(3)
    end
  end
end
