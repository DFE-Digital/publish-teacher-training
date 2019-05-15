require 'rails_helper'

describe SearchAndCompare::CourseSerializer do
  let(:course) { create :course }

  describe 'json output' do
    subject { serialize(course, serializer_class: described_class) }

    context 'an existing course' do
      let(:accrediting_provider) do
        create :provider,
               provider_code: 'M80',
               provider_name: 'Middlesex University'
      end
      let(:provider) do
        create :provider,
               provider_code: '189',
               provider_name: 'Bowes Primary School'
      end
      let(:course) do
        create :course,
               provider: provider,
               course_code: '22FV',
               accrediting_provider: accrediting_provider
      end
      let(:expected_json) do
        <<~EOJSON
          {
            "Id": 0,
            "Name": "Primary",
            "ProgrammeCode": "22FV",
            "ProviderCodeName": null,
            "ProviderId": 0,
            "Provider": {
              "Id": 0,
              "Name": "Bowes Primary School",
              "ProviderCode": "189",
              "Courses": null,
              "AccreditedCourses": null
            },
            "AccreditingProviderId": null,
            "AccreditingProvider": {
              "Id": 0,
              "Name": "Middlesex University",
              "ProviderCode": "M80",
              "Courses": null,
              "AccreditedCourses": null
            },
            "AgeRange": 0,
            "RouteId": 0,
            "Route": {
              "Id": 0,
              "Name": "School Direct (salaried) training programme",
              "IsSalaried": true,
              "Courses": null
            },
            "IncludesPgce": 1,
            "DescriptionSections": [
              {
                "Id": 0,
                "Ordinal": 0,
                "Name": "about this training programme",
                "Text": "School Direct is a school-led teacher training route where the majority of your time will be spent in your training school. The content and the focus of the training programme will be targeted to meet your individual needs. You will also have the benefit of receiving training from Middlesex University and making use of their extensive resources, including the library and student support services. \r\n\r\nOur School Direct programme also provides you with the opportunity to gain a postgraduate qualification (PGCert Teaching), which can be used towards a Masters award in the future. This will enable you to develop your skills for teaching and for understanding the interrelationship between learning and teaching, as you develop into a critically reflective practitioner. ",
                "CourseId": 0,
                "Course": null
              },
              {
                "Id": 0,
                "Ordinal": 0,
                "Name": "interview process",
                "Text": "Bowes Primary School, as the Lead school in the partnership, will coordinate the selection and recruitment process. If shortlisted for interview, candidates will spend a full day in school participating in the following: \r\n\r\n* A 20 minute observed session with a small group of children \r\n* A written task\r\n* Presentation\r\n* Group discussion\r\n* A formal individual interview\r\n\r\nMembers of the partnership and Middlesex University will be involved throughout the day and will have an equal say in the selection. It is a rigorous and thorough process to ensure applicants are matched to the employing school.  ",
                "CourseId": 0,
                "Course": null
              },
              {
                "Id": 0,
                "Ordinal": 0,
                "Name": "about fees",
                "Text": null,
                "CourseId": 0,
                "Course": null
              },
              {
                "Id": 0,
                "Ordinal": 0,
                "Name": "about salary",
                "Text": "All of our School Direct (salaried) trainees are paid on the Unqualified Teacher Pay Scale (Outer London) at a minimum of Point 1. \r\n\r\nThere are no fees to be paid by the candidate. \r\n\r\nThe PGCert element of the programme does not involve a cost to the candidate. ",
                "CourseId": 0,
                "Course": null
              },
              {
                "Id": 0,
                "Ordinal": 0,
                "Name": "entry requirements",
                "Text": "You should be a graduate with the following qualifications: \r\n\r\n* A bachelor degree (2:2 or higher)\r\n* GCSE grade C/grade 4, or equivalent, in English, Mathematics and Science. \r\n* We also accept equivalency tests by Equivalency Testing and A Star Teachers. ",
                "CourseId": 0,
                "Course": null
              },
              {
                "Id": 0,
                "Ordinal": 0,
                "Name": "entry requirements personal qualities",
                "Text": "We are looking for creative, enthusiastic and hard working trainee teachers who can bring learning to life for our children. Every day in school is different so you will need to be flexible and adaptable. We would like you to have had some experience of working with young people of primary age, but this does not need to be paid work. It could be helping with a sports team, drama group, youth group or voluntary work in schools. We welcome career changers and the skills that can be transferred between professions. ",
                "CourseId": 0,
                "Course": null
              },
              {
                "Id": 0,
                "Ordinal": 0,
                "Name": "entry requirements other",
                "Text": null,
                "CourseId": 0,
                "Course": null
              },
              {
                "Id": 0,
                "Ordinal": 0,
                "Name": "financial support",
                "Text": null,
                "CourseId": 0,
                "Course": null
              },
              {
                "Id": 0,
                "Ordinal": 0,
                "Name": "about school placements",
                "Text": "The schools within our partnership are all located within the London Borough of Enfield. When identifying schools for each candidate we consider home locations and travel options. All of our schools have good public transport links. \r\nThe teaching age ranges that we can offer are within the primary phase (3 -11). \r\nOur current partnership includes approx. 10 Enfield primary schools. \r\nThe majority of your training year will be spent in your employing school, however there is a second setting placement in one of our partnership schools for half a term (6 weeks). \r\n",
                "CourseId": 0,
                "Course": null
              },
              {
                "Id": 0,
                "Ordinal": 0,
                "Name": "about this training provider",
                "Text": null,
                "CourseId": 0,
                "Course": null
              },
              {
                "Id": 0,
                "Ordinal": 0,
                "Name": "about this training provider accrediting",
                "Text": "",
                "CourseId": 0,
                "Course": null
              },
              {
                "Id": 0,
                "Ordinal": 0,
                "Name": "training with disabilities",
                "Text": null,
                "CourseId": 0,
                "Course": null
              }
            ],
            "Campuses": [
              {
                "Id": 0,
                "Name": "Bowes Primary School",
                "CampusCode": "B",
                "LocationId": null,
                "VacStatus": "F",
                "Location": {
                  "Id": 0,
                  "Address": "Bowes Road, London N11 2HL",
                  "FormattedAddress": null,
                  "GeoAddress": null,
                  "Latitude": null,
                  "Longitude": null,
                  "LastGeocodedUtc": "0001-01-01T00:00:00"
                },
                "Course": null
              }
            ],
            "CourseSubjects": [
              {
                "CourseId": 0,
                "Course": null,
                "SubjectId": 0,
                "Subject": {
                  "Id": 0,
                  "SubjectArea": null,
                  "FundingId": null,
                  "Funding": null,
                  "Name": "Primary",
                  "IsSubjectKnowledgeEnhancementAvailable": false,
                  "CourseSubjects": null
                }
              }
            ],
            "Fees": {
              "Uk": 0,
              "Eu": 0,
              "International": 0
            },
            "IsSalaried": true,
            "Salary": {
              "Minimum": null,
              "Maximum": null
            },
            "ProviderLocationId": null,
            "ProviderLocation": {
              "Id": 0,
              "Address": "Bowes Road\nNew Southgate\nLondon\nN11 2HL",
              "FormattedAddress": null,
              "GeoAddress": null,
              "Latitude": null,
              "Longitude": null,
              "LastGeocodedUtc": "0001-01-01T00:00:00"
            },
            "Distance": null,
            "DistanceAddress": null,
            "ContactDetailsId": null,
            "ContactDetails": {
              "Id": 0,
              "Phone": "0208 368 2552",
              "Fax": null,
              "Email": "kelly.hitchcock@bowesprimaryelt.org",
              "Website": "http://www.bowesprimaryschool.org",
              "Address": "Bowes Road\nNew Southgate\nLondon\nN11 2HL",
              "Course": null
            },
            "FullTime": 1,
            "PartTime": 3,
            "ApplicationsAcceptedFrom": "2018-10-09T00:00:00",
            "StartDate": "2019-09-01T00:00:00",
            "Duration": "1 year",
            "Mod": "PGCE with QTS full time with salary",
            "HasVacancies": true,
            "IsSen": false
          }
        EOJSON
      end

      it { should include(Name: course.name) }
      it { should include(ProgrammeCode: course.course_code) }

      xit { should eq expected_json }
    end
  end
end
