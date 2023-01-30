# frozen_string_literal: true

require 'rails_helper'

describe 'GET v3 /subjects', :with_publish_constraint do
  let(:request_path) { '/api/v3/subjects' }
  let(:json_response) { JSON.parse(response.body) }

  before do
    get request_path
  end

  it 'returns the correct data' do
    expect(json_response).to eq(
      'data' => [
        {
          'id' => '1',
          'type' => 'subjects',
          'attributes' => {
            'subject_name' => 'Primary',
            'subject_code' => '00',
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
            'subject_name' => 'Primary with English',
            'subject_code' => '01',
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
            'subject_name' => 'Primary with geography and history',
            'subject_code' => '02',
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
            'subject_name' => 'Primary with mathematics',
            'subject_code' => '03',
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
            'subject_name' => 'Primary with modern languages',
            'subject_code' => '04',
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
            'subject_name' => 'Primary with physical education',
            'subject_code' => '06',
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
            'subject_name' => 'Primary with science',
            'subject_code' => '07',
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
            'subject_name' => 'Art and design',
            'subject_code' => 'W1',
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
            'subject_name' => 'Science',
            'subject_code' => 'F0',
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
            'subject_name' => 'Biology',
            'subject_code' => 'C1',
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
            'subject_name' => 'Business studies',
            'subject_code' => '08',
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
            'subject_name' => 'Chemistry',
            'subject_code' => 'F1',
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
            'subject_name' => 'Citizenship',
            'subject_code' => '09',
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
            'subject_name' => 'Classics',
            'subject_code' => 'Q8',
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
            'subject_name' => 'Communication and media studies',
            'subject_code' => 'P3',
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
            'subject_name' => 'Computing',
            'subject_code' => '11',
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
            'subject_name' => 'Dance',
            'subject_code' => '12',
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
            'subject_name' => 'Design and technology',
            'subject_code' => 'DT',
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
            'subject_name' => 'Drama',
            'subject_code' => '13',
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
            'subject_name' => 'Economics',
            'subject_code' => 'L1',
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
            'subject_name' => 'English',
            'subject_code' => 'Q3',
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
            'subject_name' => 'Geography',
            'subject_code' => 'F8',
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
            'subject_name' => 'Health and social care',
            'subject_code' => 'L5',
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
            'subject_name' => 'History',
            'subject_code' => 'V1',
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
            'subject_name' => 'Mathematics',
            'subject_code' => 'G1',
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
            'subject_name' => 'Music',
            'subject_code' => 'W3',
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
            'subject_name' => 'Philosophy',
            'subject_code' => 'P1',
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
            'subject_name' => 'Physical education',
            'subject_code' => 'C6',
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
            'subject_name' => 'Physics',
            'subject_code' => 'F3',
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
            'subject_name' => 'Psychology',
            'subject_code' => 'C8',
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
            'subject_name' => 'Religious education',
            'subject_code' => 'V6',
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
            'subject_name' => 'Social sciences',
            'subject_code' => '14',
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
            'subject_name' => 'Modern Languages',
            'subject_code' => nil,
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
            'subject_name' => 'Latin',
            'subject_code' => 'A0',
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
            'subject_name' => 'Ancient Greek',
            'subject_code' => 'A1',
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
            'subject_name' => 'Ancient Hebrew',
            'subject_code' => 'A2',
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
            'subject_name' => 'Physical education with an EBacc subject',
            'subject_code' => 'C7',
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
            'subject_name' => 'French',
            'subject_code' => '15',
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
            'subject_name' => 'English as a second or other language',
            'subject_code' => '16',
            'bursary_amount' => nil,
            'early_career_payments' => nil,
            'scholarship' => nil,
            'subject_knowledge_enhancement_course_available' => nil
          }
        },
        {
          'id' => '40',
          'type' => 'subjects',
          'attributes' => {
            'subject_name' => 'German',
            'subject_code' => '17',
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
            'subject_name' => 'Italian',
            'subject_code' => '18',
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
            'subject_name' => 'Japanese',
            'subject_code' => '19',
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
            'subject_name' => 'Mandarin',
            'subject_code' => '20',
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
            'subject_name' => 'Russian',
            'subject_code' => '21',
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
            'subject_name' => 'Spanish',
            'subject_code' => '22',
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
            'subject_name' => 'Modern languages (other)',
            'subject_code' => '24',
            'bursary_amount' => '10000',
            'early_career_payments' => nil,
            'scholarship' => nil,
            'subject_knowledge_enhancement_course_available' => false
          }
        },
        {
          'id' => '47',
          'type' => 'subjects',
          'attributes' => {
            'subject_name' => 'Further education',
            'subject_code' => '41',
            'bursary_amount' => nil,
            'early_career_payments' => nil,
            'scholarship' => nil,
            'subject_knowledge_enhancement_course_available' => nil
          }
        }
      ],
      'jsonapi' => {
        'version' => '1.0'
      }
    )
  end

  context 'when specifying particular fields' do
    let(:request_path) { '/api/v3/subjects?fields[subjects]=subject_name' }

    it 'returns the correct data' do
      expect(json_response).to eq(
        'data' => [
          {
            'id' => '1',
            'type' => 'subjects',
            'attributes' => {
              'subject_name' => 'Primary'
            }
          },
          {
            'id' => '2',
            'type' => 'subjects',
            'attributes' => {
              'subject_name' => 'Primary with English'
            }
          },
          {
            'id' => '3',
            'type' => 'subjects',
            'attributes' => {
              'subject_name' => 'Primary with geography and history'
            }
          },
          {
            'id' => '4',
            'type' => 'subjects',
            'attributes' => {
              'subject_name' => 'Primary with mathematics'
            }
          },
          {
            'id' => '5',
            'type' => 'subjects',
            'attributes' => {
              'subject_name' => 'Primary with modern languages'
            }
          },
          {
            'id' => '6',
            'type' => 'subjects',
            'attributes' => {
              'subject_name' => 'Primary with physical education'
            }
          },
          {
            'id' => '7',
            'type' => 'subjects',
            'attributes' => {
              'subject_name' => 'Primary with science'
            }
          },
          {
            'id' => '8',
            'type' => 'subjects',
            'attributes' => {
              'subject_name' => 'Art and design'
            }
          },
          {
            'id' => '9',
            'type' => 'subjects',
            'attributes' => {
              'subject_name' => 'Science'
            }
          },
          {
            'id' => '10',
            'type' => 'subjects',
            'attributes' => {
              'subject_name' => 'Biology'
            }
          },
          {
            'id' => '11',
            'type' => 'subjects',
            'attributes' => {
              'subject_name' => 'Business studies'
            }
          },
          {
            'id' => '12',
            'type' => 'subjects',
            'attributes' => {
              'subject_name' => 'Chemistry'
            }
          },
          {
            'id' => '13',
            'type' => 'subjects',
            'attributes' => {
              'subject_name' => 'Citizenship'
            }
          },
          {
            'id' => '14',
            'type' => 'subjects',
            'attributes' => {
              'subject_name' => 'Classics'
            }
          },
          {
            'id' => '15',
            'type' => 'subjects',
            'attributes' => {
              'subject_name' => 'Communication and media studies'
            }
          },
          {
            'id' => '16',
            'type' => 'subjects',
            'attributes' => {
              'subject_name' => 'Computing'
            }
          },
          {
            'id' => '17',
            'type' => 'subjects',
            'attributes' => {
              'subject_name' => 'Dance'
            }
          },
          {
            'id' => '18',
            'type' => 'subjects',
            'attributes' => {
              'subject_name' => 'Design and technology'
            }
          },
          {
            'id' => '19',
            'type' => 'subjects',
            'attributes' => {
              'subject_name' => 'Drama'
            }
          },
          {
            'id' => '20',
            'type' => 'subjects',
            'attributes' => {
              'subject_name' => 'Economics'
            }
          },
          {
            'id' => '21',
            'type' => 'subjects',
            'attributes' => {
              'subject_name' => 'English'
            }
          },
          {
            'id' => '22',
            'type' => 'subjects',
            'attributes' => {
              'subject_name' => 'Geography'
            }
          },
          {
            'id' => '23',
            'type' => 'subjects',
            'attributes' => {
              'subject_name' => 'Health and social care'
            }
          },
          {
            'id' => '24',
            'type' => 'subjects',
            'attributes' => {
              'subject_name' => 'History'
            }
          },
          {
            'id' => '25',
            'type' => 'subjects',
            'attributes' => {
              'subject_name' => 'Mathematics'
            }
          },
          {
            'id' => '26',
            'type' => 'subjects',
            'attributes' => {
              'subject_name' => 'Music'
            }
          },
          {
            'id' => '27',
            'type' => 'subjects',
            'attributes' => {
              'subject_name' => 'Philosophy'
            }
          },
          {
            'id' => '28',
            'type' => 'subjects',
            'attributes' => {
              'subject_name' => 'Physical education'
            }
          },
          {
            'id' => '29',
            'type' => 'subjects',
            'attributes' => {
              'subject_name' => 'Physics'
            }
          },
          {
            'id' => '30',
            'type' => 'subjects',
            'attributes' => {
              'subject_name' => 'Psychology'
            }
          },
          {
            'id' => '31',
            'type' => 'subjects',
            'attributes' => {
              'subject_name' => 'Religious education'
            }
          },
          {
            'id' => '32',
            'type' => 'subjects',
            'attributes' => {
              'subject_name' => 'Social sciences'
            }
          },
          {
            'id' => '33',
            'type' => 'subjects',
            'attributes' => {
              'subject_name' => 'Modern Languages'
            }
          },
          {
            'id' => '34',
            'type' => 'subjects',
            'attributes' => {
              'subject_name' => 'Latin'
            }
          },
          {
            'id' => '35',
            'type' => 'subjects',
            'attributes' => {
              'subject_name' => 'Ancient Greek'
            }
          },
          {
            'id' => '36',
            'type' => 'subjects',
            'attributes' => {
              'subject_name' => 'Ancient Hebrew'
            }
          },
          {
            'id' => '37',
            'type' => 'subjects',
            'attributes' => {
              'subject_name' => 'Physical education with an EBacc subject'
            }
          },
          {
            'id' => '38',
            'type' => 'subjects',
            'attributes' => {
              'subject_name' => 'French'
            }
          },
          {
            'id' => '39',
            'type' => 'subjects',
            'attributes' => {
              'subject_name' => 'English as a second or other language'
            }
          },
          {
            'id' => '40',
            'type' => 'subjects',
            'attributes' => {
              'subject_name' => 'German'
            }
          },
          {
            'id' => '41',
            'type' => 'subjects',
            'attributes' => {
              'subject_name' => 'Italian'
            }
          },
          {
            'id' => '42',
            'type' => 'subjects',
            'attributes' => {
              'subject_name' => 'Japanese'
            }
          },
          {
            'id' => '43',
            'type' => 'subjects',
            'attributes' => {
              'subject_name' => 'Mandarin'
            }
          },
          {
            'id' => '44',
            'type' => 'subjects',
            'attributes' => {
              'subject_name' => 'Russian'
            }
          },
          {
            'id' => '45',
            'type' => 'subjects',
            'attributes' => {
              'subject_name' => 'Spanish'
            }
          },
          {
            'id' => '46',
            'type' => 'subjects',
            'attributes' => {
              'subject_name' => 'Modern languages (other)'
            }
          },
          {
            'id' => '47',
            'type' => 'subjects',
            'attributes' => {
              'subject_name' => 'Further education'
            }
          }
        ],
        'jsonapi' => {
          'version' => '1.0'
        }
      )
    end

    context 'when sorting by name' do
      let(:request_path) { '/api/v3/subjects?fields[subjects]=subject_name&sort=subject_name' }

      it 'sorts the subject names in ascending order' do
        expect(json_response['data'].map { |subject| subject['attributes']['subject_name'] }).to eq([
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
                                                                                                      'English as a second or other language',
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
