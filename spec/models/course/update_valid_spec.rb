describe Course, type: :model do
  describe '#update_valid' do
    context 'applications_open_from' do
      let(:course) { create(:course, applications_open_from: DateTime.new(2018, 10, 1)) }

      subject { course }

      context 'for the current recruitment cycle' do
        context 'with a valid date' do
          its(:update_valid?) { should be true }
        end

        context 'with an invalid date' do
          let(:course) { create(:course, applications_open_from: DateTime.new(2019, 10, 1)) }
          its(:update_valid?) { should be false }
        end
      end

      context 'for the next recruitment cycle' do
        let(:provider) { build(:provider, recruitment_cycle: next_recruitment_cycle) }
        let(:next_recruitment_cycle) { create(:recruitment_cycle, year: '2020') }

        context 'with a valid date' do
          let(:course) { create(:course, provider: provider, applications_open_from: DateTime.new(2019, 10, 1)) }
          its(:update_valid?) { should be true }
        end

        context 'with an invalid date' do
          let(:course) { create(:course, provider: provider, applications_open_from: DateTime.new(2018, 10, 1)) }
          its(:update_valid?) { should be false }
        end
      end
    end

    context 'start_date' do
      let(:course) { create(:course, start_date: DateTime.new(2019, 9, 1)) }

      subject { course }

      context 'for the current recruitment cycle' do
        context 'with a valid start date' do
          its(:update_valid?) { should be true }
        end

        context 'with an invalid start date' do
          let(:course) { create(:course, start_date: DateTime.new(2020, 9, 1)) }
          its(:update_valid?) { should be false }
        end
      end

      context 'for the next recruitment cycle' do
        let(:provider) { build(:provider, recruitment_cycle: next_recruitment_cycle) }
        let(:next_recruitment_cycle) { create(:recruitment_cycle, year: '2020') }

        context 'with a valid start date' do
          let(:course) { create(:course, provider: provider, start_date: DateTime.new(2020, 9, 1)) }
          its(:update_valid?) { should be true }
        end

        context 'with an invalid start date' do
          let(:course) { create(:course, provider: provider, start_date: DateTime.new(2019, 9, 1)) }
          its(:update_valid?) { should be false }
        end
      end
    end

    describe 'program_type' do
      context 'self accredited' do
        context 'by a scitt' do
          let(:course) { create(:course, :with_scitt, provider: provider) }
          let(:provider) { build(:provider, scitt: 'Y') }

          it 'should return true when updated to :pg_teaching_apprenticeship' do
            course.program_type = :pg_teaching_apprenticeship
            expect(course.update_valid?).to eq true
          end

          it 'should return true when updated to :scitt_programme' do
            course.update(program_type: :pg_teaching_apprenticeship)
            course.program_type = :scitt_programme
            expect(course.update_valid?).to eq true
          end

          it 'should return false when updated to :higher_education_programme' do
            course.program_type = :higher_education_programme
            expect(course.update_valid?).to eq false
          end

          it 'should return false when updated to :school_direct_training_programme' do
            course.program_type = :school_direct_training_programme
            expect(course.update_valid?).to eq false
          end

          it 'should return false when updated to :school_direct_salaried_training_programme' do
            course.program_type = :school_direct_salaried_training_programme
            expect(course.update_valid?).to eq false
          end
        end

        context 'by a university' do
          let(:course) { create(:course, :with_higher_education, provider: provider) }
          let(:provider) { build(:provider, scitt: nil) }

          it 'should return true when updated to :pg_teaching_apprenticeship' do
            course.program_type = :pg_teaching_apprenticeship
            expect(course.update_valid?).to eq true
          end

          it 'should return true when updated to :higher_education_programme' do
            course.update(program_type: :pg_teaching_apprenticeship)
            course.program_type = :higher_education_programme
            expect(course.update_valid?).to eq true
          end

          it 'should return false when updated to :scitt_programme' do
            course.program_type = :scitt_programme
            expect(course.update_valid?).to eq false
          end

          it 'should return false when updated to :school_direct_training_programme' do
            course.program_type = :school_direct_training_programme
            expect(course.update_valid?).to eq false
          end

          it 'should return false when updated to :school_direct_salaried_training_programme' do
            course.program_type = :school_direct_salaried_training_programme
            expect(course.update_valid?).to eq false
          end
        end
      end

      context 'externally accredited' do
        let(:course) { create(:course, :with_accrediting_provider, :with_school_direct) }

        it 'should return true when updated to :pg_teaching_apprenticeship' do
          course.program_type = :pg_teaching_apprenticeship
          expect(course.update_valid?).to eq true
        end

        it 'should return true when updated to :school_direct_salaried_training_programme' do
          course.program_type = :school_direct_salaried_training_programme
          expect(course.update_valid?).to eq true
        end

        it 'should return true when updated to :school_direct_training_programme' do
          course.update(program_type: :school_direct_salaried_training_programme)
          course.program_type = :school_direct_training_programme
          expect(course.update_valid?).to eq true
        end

        it 'should return false when updated to :higher_education_programme' do
          course.program_type = :higher_education_programme
          expect(course.update_valid?).to eq false
        end

        it 'should return false when updated to :scitt_programme' do
          course.program_type = :scitt_programme
          expect(course.update_valid?).to eq false
        end
      end
    end
  end
end
