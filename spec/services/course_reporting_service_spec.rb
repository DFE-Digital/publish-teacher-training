require "rails_helper"

describe CourseReportingService do
  let(:closed_courses_scope) { class_double(Course) }
  let(:closed_courses_provider_type_scope) { class_double(Course) }
  let(:closed_courses_program_type_scope) { class_double(Course) }
  let(:closed_courses_study_mode_scope) { class_double(Course) }
  let(:closed_courses_qualification_scope) { class_double(Course) }
  let(:closed_courses_is_send_scope) { class_double(Course) }
  let(:closed_course_subjects) { class_double(CourseSubject) }
  let(:closed_course_subjects_grouped) { class_double(CourseSubject) }

  let(:courses_scope) { class_double(Course) }
  let(:findable_courses_scope) { class_double(Course) }

  let(:open_courses_scope) { class_double(Course) }
  let(:open_courses_provider_type_scope) { class_double(Course) }
  let(:open_courses_program_type_scope) { class_double(Course) }
  let(:open_courses_study_mode_scope) { class_double(Course) }
  let(:open_courses_qualification_scope) { class_double(Course) }
  let(:open_courses_is_send_scope) { class_double(Course) }
  let(:open_course_subjects) { class_double(CourseSubject) }
  let(:open_course_subjects_grouped) { class_double(CourseSubject) }

  let(:distinct_courses_scope) { class_double(Course) }

  let(:courses_count) { 100 }
  let(:findable_courses_count) { 60 }
  let(:open_courses_count) { 40 }
  let(:closed_courses_count) { 20 }

  let(:expected) do
    {
      total: {
        all: courses_count,
        non_findable: courses_count - findable_courses_count,
        all_findable: findable_courses_count,
      },
      findable_total: {
        open: open_courses_count,
        closed: closed_courses_count,
      },
      provider_type: {
        open: {
          scitt: 1, lead_school: 2, university: 3, unknown: 4, invalid_value: 5
        },
        closed: {
          scitt: 0, lead_school: 0, university: 0, unknown: 0, invalid_value: 0
        },
      },
      program_type: {
        open: {
          higher_education_programme: 1, school_direct_training_programme: 2,
          school_direct_salaried_training_programme: 3, scitt_programme: 4,
          pg_teaching_apprenticeship: 5
        },
        closed: {
          higher_education_programme: 0, school_direct_training_programme: 0,
          school_direct_salaried_training_programme: 0, scitt_programme: 0,
          pg_teaching_apprenticeship: 0
        },
      },
      study_mode: {
        open: { full_time: 1, part_time: 2, full_time_or_part_time: 3 },
        closed: { full_time: 0, part_time: 0, full_time_or_part_time: 0 },
      },
      qualification: {
        open: {
          qts: 1, pgce_with_qts: 2, pgde_with_qts: 3, pgce: 4, pgde: 5
        },
        closed: {
          qts: 0, pgce_with_qts: 0, pgde_with_qts: 0, pgce: 0, pgde: 0
        },
      },
      is_send: {
        open: { yes: 1, no: 2 },
        closed:  { yes: 0, no: 0 },
      },
      subject: {
        open: Subject.active.each_with_index.map { |sub, i| x = {}; x[sub.subject_name] = (i + 1) * 3; x }.reduce({}, :merge),
        closed: Subject.active.each_with_index.map { |sub, _i| x = {}; x[sub.subject_name] = 0; x }.reduce({}, :merge),
      },
    }
  end

  describe ".call" do
    describe "when scope is passed" do
      subject { described_class.call(courses_scope: courses_scope) }

      it "applies the scopes" do
        expect(courses_scope).to receive_message_chain(:distinct).and_return(distinct_courses_scope)
        expect(distinct_courses_scope).to receive_message_chain(:count).and_return(courses_count)
        expect(distinct_courses_scope).to receive_message_chain(:count).and_return(courses_count)
        expect(distinct_courses_scope).to receive_message_chain(:findable).and_return(findable_courses_scope)

        expect(findable_courses_scope).to receive_message_chain(:with_vacancies).and_return(open_courses_scope)
        expect(findable_courses_scope).to receive_message_chain(:where, :not).and_return(closed_courses_scope)

        expect(findable_courses_scope).to receive_message_chain(:count).and_return(findable_courses_count)
        expect(findable_courses_scope).to receive_message_chain(:count).and_return(findable_courses_count)
        expect(open_courses_scope).to receive_message_chain(:count).and_return(open_courses_count)

        expect(open_courses_scope).to receive_message_chain(:group).with(:provider_type).and_return(open_courses_provider_type_scope)
        expect(open_courses_provider_type_scope).to receive_message_chain(:count)
          .and_return(
            { "B" => 1, "Y" => 2, "O" => 3, "" => 4, "0" => 5 },
          )

        expect(open_courses_scope).to receive_message_chain(:group).with(:program_type).and_return(open_courses_program_type_scope)
        expect(open_courses_program_type_scope).to receive_message_chain(:count)
          .and_return(
            { "higher_education_programme" => 1, "school_direct_training_programme" => 2,
            "school_direct_salaried_training_programme" => 3, "scitt_programme" => 4,
            "pg_teaching_apprenticeship" => 5 },
          )

        expect(open_courses_scope).to receive_message_chain(:group).with(:study_mode).and_return(open_courses_study_mode_scope)
        expect(open_courses_study_mode_scope).to receive_message_chain(:count)
          .and_return(
            { "full_time" => 1, "part_time" => 2, "full_time_or_part_time" => 3 },
          )

        expect(open_courses_scope).to receive_message_chain(:group).with(:qualification).and_return(open_courses_qualification_scope)
        expect(open_courses_qualification_scope).to receive_message_chain(:count)
          .and_return(
            { "qts" => 1, "pgce_with_qts" => 2, "pgde_with_qts" => 3, "pgce" => 4, "pgde" => 5 },
          )

        expect(open_courses_scope).to receive_message_chain(:group).with(:is_send).and_return(open_courses_is_send_scope)
        expect(open_courses_is_send_scope).to receive_message_chain(:count)
          .and_return({ true => 1, false => 2 })

        expect(CourseSubject).to receive_message_chain(:where).with(course_id: open_courses_scope).and_return(open_course_subjects)

        expect(open_course_subjects).to receive_message_chain(:group).with(:subject_id).and_return(open_course_subjects_grouped)
        expect(open_course_subjects_grouped).to receive_message_chain(:count).and_return(
          Subject.active.each_with_index.map { |sub, i| x = {}; x[sub.id] = (i + 1) * 3; x }.reduce({}, :merge),
          )

        expect(closed_courses_scope).to receive_message_chain(:count).and_return(closed_courses_count)

        expect(closed_courses_scope).to receive_message_chain(:group).with(:provider_type).and_return(closed_courses_provider_type_scope)
        expect(closed_courses_provider_type_scope).to receive_message_chain(:count).and_return({})

        expect(closed_courses_scope).to receive_message_chain(:group).with(:program_type).and_return(closed_courses_program_type_scope)
        expect(closed_courses_program_type_scope).to receive_message_chain(:count).and_return({})

        expect(closed_courses_scope).to receive_message_chain(:group).with(:study_mode).and_return(closed_courses_study_mode_scope)
        expect(closed_courses_study_mode_scope).to receive_message_chain(:count).and_return({})

        expect(closed_courses_scope).to receive_message_chain(:group).with(:qualification).and_return(closed_courses_qualification_scope)
        expect(closed_courses_qualification_scope).to receive_message_chain(:count).and_return({})

        expect(closed_courses_scope).to receive_message_chain(:group).with(:is_send).and_return(closed_courses_is_send_scope)
        expect(closed_courses_is_send_scope).to receive_message_chain(:count).and_return({})

        expect(CourseSubject).to receive_message_chain(:where).with(course_id: closed_courses_scope).and_return(closed_course_subjects)
        expect(closed_course_subjects).to receive_message_chain(:group).with(:subject_id).and_return(closed_course_subjects_grouped)

        expect(closed_course_subjects_grouped).to receive_message_chain(:count).and_return({})

        expect(subject).to eq(expected)
      end
    end
  end
end
