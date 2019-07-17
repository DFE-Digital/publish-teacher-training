RSpec.describe Course, type: :model do
  describe '#update_courses_gcse_requirements' do
    let(:course) { create(:course, english: 1, maths: 1, science: 1) }

    subject { course }

    before do
      course.update_courses_gcse_requirements(params)
    end

    context 'with a course with updated gcse requirements' do
      context 'when all requirements are updated' do
        let(:params) { {"english"=>"expect_to_achieve_before_training_begins",
                        "maths"=>"expect_to_achieve_before_training_begins",
                        "science"=>"expect_to_achieve_before_training_begins"} }

        its(:english_before_type_cast) { should eq 2 }
        its(:maths_before_type_cast) { should eq 2 }
        its(:science_before_type_cast) { should eq 2 }
      end

      context 'when some requirements are updated and some remain the same' do
        let(:params) { {"english"=>"expect_to_achieve_before_training_begins",
                        "maths"=>"must_have_qualification_at_application_time",
                        "science"=>"equivalence_test"} }

        its(:english_before_type_cast) { should eq 2 }
        its(:maths_before_type_cast) { should eq 1 }
        its(:science_before_type_cast) { should eq 3 }
      end
    end

    context 'with a course where no requirments have been changed' do

        context 'when some requirements are updated and some remain the same' do
          let(:params) { {"english"=>"expect_to_achieve_before_training_begins",
                          "maths"=>"must_have_qualification_at_application_time",
                          "science"=>"equivalence_test"} }

          its(:english_before_type_cast) { should eq 2 }
          its(:maths_before_type_cast) { should eq 1 }
          its(:science_before_type_cast) { should eq 3 }
        end
    end
end
