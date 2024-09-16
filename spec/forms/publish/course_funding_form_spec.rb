# frozen_string_literal: true

require 'rails_helper'

describe Publish::CourseFundingForm, type: :model do
  subject { described_class.new(course, params:) }

  let(:course) { create(:course, :fee_type_based, funding: 'fee') }
  let(:course_store) { double(Stores::CourseStore) }
  let(:params) { {} }

  before do
    allow(course_store).to receive(:get).and_return(nil)
  end

  describe 'validations' do
    before { subject.validate }

    context 'funding type is blank' do
      let(:params) { { funding: nil } }

      it 'is blank' do
        expect(subject.errors[:funding]).to include('Select a funding type')
        expect(subject.valid?).to be(false)
      end
    end

    context 'can_sponsor_student_visa is nil' do
      let(:params) { { can_sponsor_student_visa: nil } }

      it 'is invalid' do
        expect(subject.errors[:can_sponsor_student_visa]).to include('Select an option')
        expect(subject.valid?).to be(false)
      end
    end

    context 'can_sponsor_skilled_worker_visa is nil' do
      let(:course) { create(:course, :with_salary) }
      let(:params) { { can_sponsor_skilled_worker_visa: nil } }

      it 'is invalid' do
        expect(subject.errors[:can_sponsor_skilled_worker_visa]).to include('Select an option')
        expect(subject.valid?).to be(false)
      end
    end

    describe '#funding_updated?' do
      context 'when updated funding type is different' do
        let(:params) { { funding: 'salary' } }

        it 'returns true' do
          expect(subject.funding_updated?).to be true
        end
      end

      context 'when updated funding type is the same' do
        let(:params) { { funding: 'fee' } }

        it 'returns false' do
          expect(subject.funding_updated?).to be false
        end
      end
    end

    describe '#origin_step' do
      context 'when updated funding type is apprenticeship' do
        let(:params) { { funding: 'apprenticeship' } }

        it 'returns apprenticeship' do
          expect(subject.origin_step).to be(:apprenticeship)
        end
      end

      context 'when updated funding type is not apprenticeship' do
        let(:params) { { funding: 'salary' } }

        it 'returns apprenticeship' do
          expect(subject.origin_step).to be(:funding)
        end
      end
    end

    describe '#is_fee_based?' do
      context 'when funding type is fee based' do
        let(:params) { { funding: 'fee' } }

        it 'returns true' do
          expect(subject.is_fee_based?).to be(true)
        end
      end

      context 'when funding type is not fee based' do
        let(:params) { { funding: 'apprenticeship' } }

        it 'returns true' do
          expect(subject.is_fee_based?).to be(false)
        end
      end
    end

    describe '#visa_type' do
      context 'when funding type is fee based' do
        let(:params) { { funding: 'fee' } }

        it 'returns student' do
          expect(subject.visa_type).to be(:student)
        end
      end

      context 'when funding type is not fee based' do
        let(:params) { { funding: 'apprenticeship' } }

        it 'returns skilled_worker' do
          expect(subject.visa_type).to be(:skilled_worker)
        end
      end
    end

    describe '#student_visa?' do
      context 'when funding type is fee based' do
        let(:params) { { funding: 'fee' } }

        it 'returns true' do
          expect(subject.student_visa?).to be(true)
        end
      end

      context 'when funding type is not fee based' do
        let(:params) { { funding: 'apprenticeship' } }

        it 'returns true' do
          expect(subject.student_visa?).to be(false)
        end
      end
    end

    describe '#skilled_worker_visa?' do
      context 'when funding type is fee based' do
        let(:params) { { funding: 'fee' } }

        it 'returns true' do
          expect(subject.skilled_worker_visa?).to be(false)
        end
      end

      context 'when funding type is not fee based' do
        let(:params) { { funding: 'apprenticeship' } }

        it 'returns true' do
          expect(subject.skilled_worker_visa?).to be(true)
        end
      end
    end

    describe 'save!' do
      context 'when the course is a fee based' do
        let(:course) { create(:course, :fee_type_based, :draft_enrichment, funding: 'fee') }

        context 'when changing funding type to apprenticeship and can sponsor skilled worker visa' do
          let(:params) { { funding: 'apprenticeship', can_sponsor_skilled_worker_visa: true } }

          it 'updates the course with the new details' do
            expect { subject.save! }
              .to change(course, :funding).from('fee').to('apprenticeship')
              .and change(course, :can_sponsor_skilled_worker_visa).from(false).to(true)
              .and change { course.enrichments.last.fee_details }.to(nil)
              .and change { course.enrichments.last.fee_international }.to(nil)
              .and change { course.enrichments.last.fee_uk_eu }.to(nil)
              .and change { course.enrichments.last.financial_support }.to(nil)
          end
        end

        context 'when changing funding type to salary and can sponsor skilled worker visa' do
          let(:params) { { funding: 'salary', can_sponsor_skilled_worker_visa: true } }

          it 'updates the course with the new details' do
            expect { subject.save! }
              .to change(course, :funding).from('fee').to('salary')
              .and change(course, :can_sponsor_skilled_worker_visa).from(false).to(true)
              .and change { course.enrichments.last.fee_details }.to(nil)
              .and change { course.enrichments.last.fee_international }.to(nil)
              .and change { course.enrichments.last.fee_uk_eu }.to(nil)
              .and change { course.enrichments.last.financial_support }.to(nil)
          end
        end
      end

      context 'when the course is with salary' do
        let(:course) { create(:course, :with_salary, :draft_enrichment, funding: 'salary') }

        context 'when changing funding type to apprenticeship and can sponsor skilled worker visa' do
          let(:params) { { funding: 'apprenticeship', can_sponsor_skilled_worker_visa: true } }

          it 'updates the course with the new details' do
            expect { subject.save! }
              .to change(course, :funding).from('salary').to('apprenticeship')
              .and change(course, :can_sponsor_skilled_worker_visa).from(false).to(true)
              .and change { course.enrichments.last.fee_details }.to(nil)
              .and change { course.enrichments.last.fee_international }.to(nil)
              .and change { course.enrichments.last.fee_uk_eu }.to(nil)
              .and change { course.enrichments.last.financial_support }.to(nil)
          end
        end

        context 'when changing funding type to fee and can sponsor student visa' do
          let(:params) { { funding: 'fee', can_sponsor_student_visa: true } }

          it 'updates the course with the new details' do
            expect { subject.save! }
              .to change(course, :funding).from('salary').to('fee')
              .and change(course, :can_sponsor_student_visa).from(false).to(true)
              .and change { course.enrichments.last.salary_details }.to(nil)
          end
        end
      end

      context 'when the course is with apprenticeship' do
        let(:course) { create(:course, :with_apprenticeship, :draft_enrichment, funding: 'apprenticeship') }

        context 'when changing funding type to salary and can sponsor skilled worker visa' do
          let(:params) { { funding: 'salary', can_sponsor_skilled_worker_visa: true } }

          it 'updates the course with the new details' do
            expect { subject.save! }
              .to change(course, :funding).from('apprenticeship').to('salary')
              .and change(course, :can_sponsor_skilled_worker_visa).from(false).to(true)
              .and change { course.enrichments.last.fee_details }.to(nil)
              .and change { course.enrichments.last.fee_international }.to(nil)
              .and change { course.enrichments.last.fee_uk_eu }.to(nil)
              .and change { course.enrichments.last.financial_support }.to(nil)
          end
        end

        context 'when changing funding type to fee and can sponsor student visa' do
          let(:params) { { funding: 'fee', can_sponsor_student_visa: true } }

          it 'updates the course with the new details' do
            expect { subject.save! }
              .to change(course, :funding).from('apprenticeship').to('fee')
              .and change(course, :can_sponsor_student_visa).from(false).to(true)
              .and change { course.enrichments.last.salary_details }.to(nil)
          end
        end
      end

      context 'blank funding' do
        let(:params) { { funding: '' } }

        it 'does not update the course with invalid details' do
          expect { subject.save! }
            .not_to(change(course, :funding))
        end
      end

      context 'student visa is nil' do
        let(:params) { { can_sponsor_student_visa: nil } }

        it 'does not update the course with invalid details' do
          expect { subject.save! }
            .not_to(change(course, :can_sponsor_student_visa))
        end
      end

      context 'skilled worker visa is nil' do
        let(:course) { create(:course, :with_salary) }
        let(:params) { { can_sponsor_skilled_worker_visa: nil } }

        it 'does not update the course with invalid details' do
          expect { subject.save! }
            .not_to(change(course, :can_sponsor_skilled_worker_visa))
        end
      end
    end

    describe '#stash' do
      context 'valid details' do
        let(:params) { { funding: 'salary', can_sponsor_skilled_worker_visa: true } }

        it 'returns true' do
          expect(subject.stash).to be true
        end
      end

      context 'blank funding' do
        let(:params) { { funding: '' } }

        it 'does not update the course with invalid details' do
          expect(subject.stash).to be_nil
          expect(subject.errors.messages).to eq({ funding: ['Select a funding type'] })
        end
      end
    end
  end
end
