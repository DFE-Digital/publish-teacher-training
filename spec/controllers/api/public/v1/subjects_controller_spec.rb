# frozen_string_literal: true

require 'rails_helper'

RSpec.describe API::Public::V1::SubjectsController do
  describe '#index' do
    before do
      get(:index, params:)
    end

    context 'when there are no params' do
      let(:params) { nil }

      it 'returns array of data' do
        expect(json_response['data']).to eql([
                                               {
                                                 'id' => '1',
                                                 'type' => 'subjects',
                                                 'attributes' => {
                                                   'name' => 'Primary',
                                                   'code' => '00',
                                                   'bursary_amount' => nil,
                                                   'early_career_payments' => nil,
                                                   'scholarship' => nil,
                                                   'subject_knowledge_enhancement_course_available' => nil
                                                 }
                                               },
                                               {
                                                 'id' => '2',
                                                 'type' => 'subjects',
                                                 'attributes' => {
                                                   'name' => 'Primary with English',
                                                   'code' => '01',
                                                   'bursary_amount' => nil,
                                                   'early_career_payments' => nil,
                                                   'scholarship' => nil,
                                                   'subject_knowledge_enhancement_course_available' => nil
                                                 }
                                               },
                                               {
                                                 'id' => '3',
                                                 'type' => 'subjects',
                                                 'attributes' => {
                                                   'name' => 'Primary with geography and history',
                                                   'code' => '02',
                                                   'bursary_amount' => nil,
                                                   'early_career_payments' => nil,
                                                   'scholarship' => nil,
                                                   'subject_knowledge_enhancement_course_available' => nil
                                                 }
                                               },
                                               {
                                                 'id' => '4',
                                                 'type' => 'subjects',
                                                 'attributes' => {
                                                   'name' => 'Primary with mathematics',
                                                   'code' => '03',
                                                   'bursary_amount' => nil,
                                                   'early_career_payments' => nil,
                                                   'scholarship' => nil,
                                                   'subject_knowledge_enhancement_course_available' => nil
                                                 }
                                               },
                                               {
                                                 'id' => '5',
                                                 'type' => 'subjects',
                                                 'attributes' => {
                                                   'name' => 'Primary with modern languages',
                                                   'code' => '04',
                                                   'bursary_amount' => nil,
                                                   'early_career_payments' => nil,
                                                   'scholarship' => nil,
                                                   'subject_knowledge_enhancement_course_available' => nil
                                                 }
                                               },
                                               {
                                                 'id' => '6',
                                                 'type' => 'subjects',
                                                 'attributes' => {
                                                   'name' => 'Primary with physical education',
                                                   'code' => '06',
                                                   'bursary_amount' => nil,
                                                   'early_career_payments' => nil,
                                                   'scholarship' => nil,
                                                   'subject_knowledge_enhancement_course_available' => nil
                                                 }
                                               },
                                               {
                                                 'id' => '7',
                                                 'type' => 'subjects',
                                                 'attributes' => {
                                                   'name' => 'Primary with science',
                                                   'code' => '07',
                                                   'bursary_amount' => nil,
                                                   'early_career_payments' => nil,
                                                   'scholarship' => nil,
                                                   'subject_knowledge_enhancement_course_available' => nil
                                                 }
                                               },
                                               {
                                                 'id' => '8',
                                                 'type' => 'subjects',
                                                 'attributes' => {
                                                   'name' => 'Art and design',
                                                   'code' => 'W1',
                                                   'bursary_amount' => nil,
                                                   'early_career_payments' => nil,
                                                   'scholarship' => nil,
                                                   'subject_knowledge_enhancement_course_available' => nil
                                                 }
                                               },
                                               {
                                                 'id' => '9',
                                                 'type' => 'subjects',
                                                 'attributes' => {
                                                   'name' => 'Science',
                                                   'code' => 'F0',
                                                   'bursary_amount' => nil,
                                                   'early_career_payments' => nil,
                                                   'scholarship' => nil,
                                                   'subject_knowledge_enhancement_course_available' => nil
                                                 }
                                               },
                                               {
                                                 'id' => '10',
                                                 'type' => 'subjects',
                                                 'attributes' => {
                                                   'name' => 'Biology',
                                                   'code' => 'C1',
                                                   'bursary_amount' => '7000',
                                                   'early_career_payments' => nil,
                                                   'scholarship' => nil,
                                                   'subject_knowledge_enhancement_course_available' => false
                                                 }
                                               },
                                               {
                                                 'id' => '11',
                                                 'type' => 'subjects',
                                                 'attributes' => {
                                                   'name' => 'Business studies',
                                                   'code' => '08',
                                                   'bursary_amount' => nil,
                                                   'early_career_payments' => nil,
                                                   'scholarship' => nil,
                                                   'subject_knowledge_enhancement_course_available' => nil
                                                 }
                                               },
                                               {
                                                 'id' => '12',
                                                 'type' => 'subjects',
                                                 'attributes' => {
                                                   'name' => 'Chemistry',
                                                   'code' => 'F1',
                                                   'bursary_amount' => '24000',
                                                   'early_career_payments' => nil,
                                                   'scholarship' => '26000',
                                                   'subject_knowledge_enhancement_course_available' => false
                                                 }
                                               },
                                               {
                                                 'id' => '13',
                                                 'type' => 'subjects',
                                                 'attributes' => {
                                                   'name' => 'Citizenship',
                                                   'code' => '09',
                                                   'bursary_amount' => nil,
                                                   'early_career_payments' => nil,
                                                   'scholarship' => nil,
                                                   'subject_knowledge_enhancement_course_available' => nil
                                                 }
                                               },
                                               {
                                                 'id' => '14',
                                                 'type' => 'subjects',
                                                 'attributes' => {
                                                   'name' => 'Classics',
                                                   'code' => 'Q8',
                                                   'bursary_amount' => '10000',
                                                   'early_career_payments' => nil,
                                                   'scholarship' => nil,
                                                   'subject_knowledge_enhancement_course_available' => false
                                                 }
                                               },
                                               {
                                                 'id' => '15',
                                                 'type' => 'subjects',
                                                 'attributes' => {
                                                   'name' => 'Communication and media studies',
                                                   'code' => 'P3',
                                                   'bursary_amount' => nil,
                                                   'early_career_payments' => nil,
                                                   'scholarship' => nil,
                                                   'subject_knowledge_enhancement_course_available' => nil
                                                 }
                                               },
                                               {
                                                 'id' => '16',
                                                 'type' => 'subjects',
                                                 'attributes' => {
                                                   'name' => 'Computing',
                                                   'code' => '11',
                                                   'bursary_amount' => '24000',
                                                   'early_career_payments' => nil,
                                                   'scholarship' => '26000',
                                                   'subject_knowledge_enhancement_course_available' => false
                                                 }
                                               },
                                               {
                                                 'id' => '17',
                                                 'type' => 'subjects',
                                                 'attributes' => {
                                                   'name' => 'Dance',
                                                   'code' => '12',
                                                   'bursary_amount' => nil,
                                                   'early_career_payments' => nil,
                                                   'scholarship' => nil,
                                                   'subject_knowledge_enhancement_course_available' => nil
                                                 }
                                               },
                                               {
                                                 'id' => '18',
                                                 'type' => 'subjects',
                                                 'attributes' => {
                                                   'name' => 'Design and technology',
                                                   'code' => 'DT',
                                                   'bursary_amount' => nil,
                                                   'early_career_payments' => nil,
                                                   'scholarship' => nil,
                                                   'subject_knowledge_enhancement_course_available' => nil
                                                 }
                                               },
                                               {
                                                 'id' => '19',
                                                 'type' => 'subjects',
                                                 'attributes' => {
                                                   'name' => 'Drama',
                                                   'code' => '13',
                                                   'bursary_amount' => nil,
                                                   'early_career_payments' => nil,
                                                   'scholarship' => nil,
                                                   'subject_knowledge_enhancement_course_available' => nil
                                                 }
                                               },
                                               {
                                                 'id' => '20',
                                                 'type' => 'subjects',
                                                 'attributes' => {
                                                   'name' => 'Economics',
                                                   'code' => 'L1',
                                                   'bursary_amount' => nil,
                                                   'early_career_payments' => nil,
                                                   'scholarship' => nil,
                                                   'subject_knowledge_enhancement_course_available' => nil
                                                 }
                                               },
                                               {
                                                 'id' => '21',
                                                 'type' => 'subjects',
                                                 'attributes' => {
                                                   'name' => 'English',
                                                   'code' => 'Q3',
                                                   'bursary_amount' => nil,
                                                   'early_career_payments' => nil,
                                                   'scholarship' => nil,
                                                   'subject_knowledge_enhancement_course_available' => nil
                                                 }
                                               },
                                               {
                                                 'id' => '22',
                                                 'type' => 'subjects',
                                                 'attributes' => {
                                                   'name' => 'Geography',
                                                   'code' => 'F8',
                                                   'bursary_amount' => nil,
                                                   'early_career_payments' => nil,
                                                   'scholarship' => nil,
                                                   'subject_knowledge_enhancement_course_available' => nil
                                                 }
                                               },
                                               {
                                                 'id' => '23',
                                                 'type' => 'subjects',
                                                 'attributes' => {
                                                   'name' => 'Health and social care',
                                                   'code' => 'L5',
                                                   'bursary_amount' => nil,
                                                   'early_career_payments' => nil,
                                                   'scholarship' => nil,
                                                   'subject_knowledge_enhancement_course_available' => nil
                                                 }
                                               },
                                               {
                                                 'id' => '24',
                                                 'type' => 'subjects',
                                                 'attributes' => {
                                                   'name' => 'History',
                                                   'code' => 'V1',
                                                   'bursary_amount' => nil,
                                                   'early_career_payments' => nil,
                                                   'scholarship' => nil,
                                                   'subject_knowledge_enhancement_course_available' => nil
                                                 }
                                               },
                                               {
                                                 'id' => '25',
                                                 'type' => 'subjects',
                                                 'attributes' => {
                                                   'name' => 'Mathematics',
                                                   'code' => 'G1',
                                                   'bursary_amount' => '24000',
                                                   'early_career_payments' => nil,
                                                   'scholarship' => '26000',
                                                   'subject_knowledge_enhancement_course_available' => false
                                                 }
                                               },
                                               {
                                                 'id' => '26',
                                                 'type' => 'subjects',
                                                 'attributes' => {
                                                   'name' => 'Music',
                                                   'code' => 'W3',
                                                   'bursary_amount' => nil,
                                                   'early_career_payments' => nil,
                                                   'scholarship' => nil,
                                                   'subject_knowledge_enhancement_course_available' => nil
                                                 }
                                               },
                                               {
                                                 'id' => '27',
                                                 'type' => 'subjects',
                                                 'attributes' => {
                                                   'name' => 'Philosophy',
                                                   'code' => 'P1',
                                                   'bursary_amount' => nil,
                                                   'early_career_payments' => nil,
                                                   'scholarship' => nil,
                                                   'subject_knowledge_enhancement_course_available' => nil
                                                 }
                                               },
                                               {
                                                 'id' => '28',
                                                 'type' => 'subjects',
                                                 'attributes' => {
                                                   'name' => 'Physical education',
                                                   'code' => 'C6',
                                                   'bursary_amount' => nil,
                                                   'early_career_payments' => nil,
                                                   'scholarship' => nil,
                                                   'subject_knowledge_enhancement_course_available' => nil
                                                 }
                                               },
                                               {
                                                 'id' => '29',
                                                 'type' => 'subjects',
                                                 'attributes' => {
                                                   'name' => 'Physics',
                                                   'code' => 'F3',
                                                   'bursary_amount' => '24000',
                                                   'early_career_payments' => nil,
                                                   'scholarship' => '26000',
                                                   'subject_knowledge_enhancement_course_available' => false
                                                 }
                                               },
                                               {
                                                 'id' => '30',
                                                 'type' => 'subjects',
                                                 'attributes' => {
                                                   'name' => 'Psychology',
                                                   'code' => 'C8',
                                                   'bursary_amount' => nil,
                                                   'early_career_payments' => nil,
                                                   'scholarship' => nil,
                                                   'subject_knowledge_enhancement_course_available' => nil
                                                 }
                                               },
                                               {
                                                 'id' => '31',
                                                 'type' => 'subjects',
                                                 'attributes' => {
                                                   'name' => 'Religious education',
                                                   'code' => 'V6',
                                                   'bursary_amount' => nil,
                                                   'early_career_payments' => nil,
                                                   'scholarship' => nil,
                                                   'subject_knowledge_enhancement_course_available' => nil
                                                 }
                                               },
                                               {
                                                 'id' => '32',
                                                 'type' => 'subjects',
                                                 'attributes' => {
                                                   'name' => 'Social sciences',
                                                   'code' => '14',
                                                   'bursary_amount' => nil,
                                                   'early_career_payments' => nil,
                                                   'scholarship' => nil,
                                                   'subject_knowledge_enhancement_course_available' => nil
                                                 }
                                               },
                                               {
                                                 'id' => '33',
                                                 'type' => 'subjects',
                                                 'attributes' => {
                                                   'name' => 'Modern Languages',
                                                   'code' => nil,
                                                   'bursary_amount' => nil,
                                                   'early_career_payments' => nil,
                                                   'scholarship' => nil,
                                                   'subject_knowledge_enhancement_course_available' => nil
                                                 }
                                               },
                                               {
                                                 'id' => '34',
                                                 'type' => 'subjects',
                                                 'attributes' => {
                                                   'name' => 'Latin',
                                                   'code' => 'A0',
                                                   'bursary_amount' => nil,
                                                   'early_career_payments' => nil,
                                                   'scholarship' => nil,
                                                   'subject_knowledge_enhancement_course_available' => nil
                                                 }
                                               },
                                               {
                                                 'id' => '35',
                                                 'type' => 'subjects',
                                                 'attributes' => {
                                                   'name' => 'Ancient Greek',
                                                   'code' => 'A1',
                                                   'bursary_amount' => nil,
                                                   'early_career_payments' => nil,
                                                   'scholarship' => nil,
                                                   'subject_knowledge_enhancement_course_available' => nil
                                                 }
                                               },
                                               {
                                                 'id' => '36',
                                                 'type' => 'subjects',
                                                 'attributes' => {
                                                   'name' => 'Ancient Hebrew',
                                                   'code' => 'A2',
                                                   'bursary_amount' => nil,
                                                   'early_career_payments' => nil,
                                                   'scholarship' => nil,
                                                   'subject_knowledge_enhancement_course_available' => nil
                                                 }
                                               },
                                               {
                                                 'id' => '37',
                                                 'type' => 'subjects',
                                                 'attributes' => {
                                                   'name' => 'Physical education with an EBacc subject',
                                                   'code' => 'C7',
                                                   'bursary_amount' => nil,
                                                   'early_career_payments' => nil,
                                                   'scholarship' => nil,
                                                   'subject_knowledge_enhancement_course_available' => nil
                                                 }
                                               },
                                               {
                                                 'id' => '38',
                                                 'type' => 'subjects',
                                                 'attributes' => {
                                                   'name' => 'French',
                                                   'code' => '15',
                                                   'bursary_amount' => '10000',
                                                   'early_career_payments' => nil,
                                                   'scholarship' => nil,
                                                   'subject_knowledge_enhancement_course_available' => false
                                                 }
                                               },
                                               {
                                                 'id' => '39',
                                                 'type' => 'subjects',
                                                 'attributes' => {
                                                   'name' => 'German',
                                                   'code' => '17',
                                                   'bursary_amount' => '10000',
                                                   'early_career_payments' => nil,
                                                   'scholarship' => nil,
                                                   'subject_knowledge_enhancement_course_available' => false
                                                 }
                                               },
                                               {
                                                 'id' => '40',
                                                 'type' => 'subjects',
                                                 'attributes' => {
                                                   'name' => 'Italian',
                                                   'code' => '18',
                                                   'bursary_amount' => '10000',
                                                   'early_career_payments' => nil,
                                                   'scholarship' => nil,
                                                   'subject_knowledge_enhancement_course_available' => false
                                                 }
                                               },
                                               {
                                                 'id' => '41',
                                                 'type' => 'subjects',
                                                 'attributes' => {
                                                   'name' => 'Japanese',
                                                   'code' => '19',
                                                   'bursary_amount' => '10000',
                                                   'early_career_payments' => nil,
                                                   'scholarship' => nil,
                                                   'subject_knowledge_enhancement_course_available' => false
                                                 }
                                               },
                                               {
                                                 'id' => '42',
                                                 'type' => 'subjects',
                                                 'attributes' => {
                                                   'name' => 'Mandarin',
                                                   'code' => '20',
                                                   'bursary_amount' => '10000',
                                                   'early_career_payments' => nil,
                                                   'scholarship' => nil,
                                                   'subject_knowledge_enhancement_course_available' => false
                                                 }
                                               },
                                               {
                                                 'id' => '43',
                                                 'type' => 'subjects',
                                                 'attributes' => {
                                                   'name' => 'Russian',
                                                   'code' => '21',
                                                   'bursary_amount' => '10000',
                                                   'early_career_payments' => nil,
                                                   'scholarship' => nil,
                                                   'subject_knowledge_enhancement_course_available' => false
                                                 }
                                               },
                                               {
                                                 'id' => '44',
                                                 'type' => 'subjects',
                                                 'attributes' => {
                                                   'name' => 'Spanish',
                                                   'code' => '22',
                                                   'bursary_amount' => '10000',
                                                   'early_career_payments' => nil,
                                                   'scholarship' => nil,
                                                   'subject_knowledge_enhancement_course_available' => false
                                                 }
                                               },
                                               {
                                                 'id' => '45',
                                                 'type' => 'subjects',
                                                 'attributes' => {
                                                   'name' => 'Modern languages (other)',
                                                   'code' => '24',
                                                   'bursary_amount' => '10000',
                                                   'early_career_payments' => nil,
                                                   'scholarship' => nil,
                                                   'subject_knowledge_enhancement_course_available' => false
                                                 }
                                               },
                                               {
                                                 'id' => '46',
                                                 'type' => 'subjects',
                                                 'attributes' => {
                                                   'name' => 'Further education',
                                                   'code' => '41',
                                                   'bursary_amount' => nil,
                                                   'early_career_payments' => nil,
                                                   'scholarship' => nil,
                                                   'subject_knowledge_enhancement_course_available' => nil
                                                 }
                                               }
                                             ])
      end
    end

    context 'when sorting by name' do
      let(:params) do
        {
          fields: {
            subjects: 'name'
          },
          sort: 'name'
        }
      end

      it 'sorts the subject names in ascending order' do
        expect(json_response['data'].map { |subject| subject['attributes']['name'] }).to eq([
                                                                                              'Ancient Greek',
                                                                                              'Ancient Hebrew',
                                                                                              'Art and design',
                                                                                              'Biology',
                                                                                              'Business studies',
                                                                                              'Chemistry',
                                                                                              'Citizenship',
                                                                                              'Classics',
                                                                                              'Communication and media studies',
                                                                                              'Computing',
                                                                                              'Dance',
                                                                                              'Design and technology',
                                                                                              'Drama',
                                                                                              'Economics',
                                                                                              'English',
                                                                                              'French',
                                                                                              'Further education',
                                                                                              'Geography',
                                                                                              'German',
                                                                                              'Health and social care',
                                                                                              'History',
                                                                                              'Italian',
                                                                                              'Japanese',
                                                                                              'Latin',
                                                                                              'Mandarin',
                                                                                              'Mathematics',
                                                                                              'Modern Languages',
                                                                                              'Modern languages (other)',
                                                                                              'Music',
                                                                                              'Philosophy',
                                                                                              'Physical education',
                                                                                              'Physical education with an EBacc subject',
                                                                                              'Physics',
                                                                                              'Primary',
                                                                                              'Primary with English',
                                                                                              'Primary with geography and history',
                                                                                              'Primary with mathematics',
                                                                                              'Primary with modern languages',
                                                                                              'Primary with physical education',
                                                                                              'Primary with science',
                                                                                              'Psychology',
                                                                                              'Religious education',
                                                                                              'Russian',
                                                                                              'Science',
                                                                                              'Social sciences',
                                                                                              'Spanish'
                                                                                            ])
      end
    end
  end
end
