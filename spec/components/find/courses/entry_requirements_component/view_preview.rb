# frozen_string_literal: true

module Find
  module Courses
    module EntryRequirementsComponent
      class ViewPreview < ViewComponent::Preview
        def qualifications_needed_only
          course = Course.new(course_code: 'FIND',
                              subjects: [Subject.new(subject_name: 'Foo', subject_code: '1')],
                              name: 'Super cool awesome course',
                              provider: Provider.new(provider_code: 'DFE', recruitment_cycle: RecruitmentCycle.current),
                              additional_degree_subject_requirements: true,
                              degree_subject_requirements: 'Degree Subject Requirements Text',
                              level: 'secondary',
                              additional_gcse_equivalencies: 'Additional GCSE Equivalencies Text')

          render Find::Courses::EntryRequirementsComponent::View.new(course: course.decorate)
        end

        def fully_populated
          render Find::Courses::EntryRequirementsComponent::View.new(course: mock_course)
        end

        def fully_populated_with_etp_course
          render Find::Courses::EntryRequirementsComponent::View.new(course: mock_etp_course)
        end

        def fully_populated_with_ske_subject
          render Find::Courses::EntryRequirementsComponent::View.new(course: mock_ske_course)
        end

        def fully_populated_with_primary_maths_subject
          render Find::Courses::EntryRequirementsComponent::View.new(course: mock_primary_maths_ske_course)
        end

        private

        def mock_etp_course
          FakeCourse.new(**mock_etp_course_attributes)
        end

        def mock_ske_course
          FakeCourse.new(**mock_ske_course_attributes)
        end

        def mock_primary_maths_ske_course
          FakeCourse.new(**mock_primary_maths_ske_course_attributes)
        end

        def mock_etp_course_attributes
          mock_course_attributes.merge({ campaign_name: :engineers_teach_physics })
        end

        def mock_ske_course_attributes
          mock_course_attributes.merge({ subjects: [Subject.new(subject_name: 'SKE Subject', subject_code: 'C1')] })
        end

        def mock_primary_maths_ske_course_attributes
          mock_course_attributes.merge({ subjects: [Subject.new(subject_name: 'Primary Maths SKE Subject', subject_code: '03')] })
        end

        def mock_course_attributes
          { degree_grade: 1,
            degree_subject_requirements: 'Degree Subject Requirements Text Goes Here',
            level: 'secondary',
            name: 'Super Awesome Course',
            gcse_grade_required: 'A*',
            accept_pending_gcse: true,
            accept_gcse_equivalency: true,
            accept_english_gcse_equivalency: true,
            accept_maths_gcse_equivalency: true,
            accept_science_gcse_equivalency: true,
            additional_gcse_equivalencies: 'much much more',
            computed_subject_name_or_names: 'Biology',
            subjects: [Subject.new(subject_name: 'foo', subject_code: 'sc')] }
        end

        def mock_course
          FakeCourse.new(**mock_course_attributes)
        end

        class FakeCourse
          include ActiveModel::Model
          attr_accessor(:degree_grade, :degree_subject_requirements, :level, :name, :gcse_grade_required, :accept_pending_gcse, :accept_gcse_equivalency, :accept_english_gcse_equivalency, :accept_maths_gcse_equivalency, :accept_science_gcse_equivalency, :additional_gcse_equivalencies, :computed_subject_name_or_names, :campaign_name, :subjects)

          def enrichment_attribute(params)
            send(params)
          end

          def accept_gcse_equivalency?
            accept_gcse_equivalency
          end

          def secondary_course?
            level == 'secondary'
          end

          def engineers_teach_physics?
            campaign_name&.to_sym == :engineers_teach_physics
          end

          def teacher_degree_apprenticeship?
            false
          end
        end
      end
    end
  end
end
