# API Reference

# Authorisation

The server expects an API key to be included in a header  for all API requests:

`Authorization: Bearer your_api_key`

<aside class="notice">
You must replace <code>your_api_key</code> with your issued API key.
</aside>


> To authorise, use this code:

```shell
# With shell, you can just pass the correct header with each request
curl "api_endpoint_here"
  -H "Authorization: Bearer your_api_key"
```

# Pagination

All endpoints return paginated results, meaning if there are more results than
the page size, multiple requests will be necessary to retrieve all the results.
Clients should use the links provided in the headers for the next pages when
retrieving the entire result-set.

> Example headers:

```
Link: <https://manage-courses-backend.herokuapp.com/api/v1/2018/courses?page=169>; rel="last", <https://manage-courses-backend.herokuapp.com/api/v1/2018/courses?page=2>; rel="next"
Per-Page: 100
Total: 16888
Last-Changed: 20190113222741
```

| Header       | Description                                                                                    |
|--------------|------------------------------------------------------------------------------------------------|
| Link         | Links to the next and last pages                                                               |
| Per-Page     | The number of results in the page                                                              |
| Total        | The total number of results                                                                    |

Behind the scenes, there are two types of pagination depending on whether all
records are being returned, or whether a list of records changed since a given
time are returned.

## All-Records Pagination

> Example page URLs:

```
https://manage-courses-backend.herokuapp.com/api/v1/2018/courses
https://manage-courses-backend.herokuapp.com/api/v1/2018/courses?page=1
https://manage-courses-backend.herokuapp.com/api/v1/2018/courses?page=2
https://manage-courses-backend.herokuapp.com/api/v1/2018/courses?page=3
```

When all records are being retrieved, pagination is done using the `page`
parameter.

## Changed-Records Pagination

> Example page URLs:

```
https://manage-courses-backend.herokuapp.com/api/v1/2018/courses?changed_since=
https://manage-courses-backend.herokuapp.com/api/v1/2018/courses?changed_since=20190113T222741Z
https://manage-courses-backend.herokuapp.com/api/v1/2018/courses?changed_since=20190114T223403Z
```

When changed records are being retrieved, pagination is done by re-using the
`changed_since` parameter. This pagination is state-less and any records that
change while the results are being retrieved will appear again in the results,
so clients should be prepared to receive duplicate records.

# Retrieving Changed Records

> Example request sequence:

```
# initial get with first page or results
> GET https://manage-courses-backend.herokuapp.com/api/v1/2018/courses?changed_since=

< Link: <https://manage-courses-backend.herokuapp.com/api/v1/2018/courses?changed_since=20190110T112846Z&changed_id=173>;rel="next"
< Per-Page: 100
< Total: 250


# second page of results
> GET https://manage-courses-backend.herokuapp.com/api/v1/2018/courses?changed_since=20190110T112846Z&changed_id=173

< Link: <https://manage-courses-backend.herokuapp.com/api/v1/2018/courses?changed_since=20190111T222741Z&changed_id=291>;rel="next"
< Per-Page: 100
< Total: 150


# last page of results with "next" link to be used later
> GET https://manage-courses-backend.herokuapp.com/api/v1/2018/courses?changed_since=20190111T222741Z&changed_id=291

< Link: <https://manage-courses-backend.herokuapp.com/api/v1/2018/courses?changed_since=20190113T120126Z&changed_id=400>;rel="next"
< Per-Page: 100
< Total: 50
```

Certain endpoints support retrieving records that have changed since a given
point in time. This is to facilitate keeping a client's database in sync with
the primary source at the DfE using incremental updates, where using the API as
a live data source is not an option.

The general pattern for how to retrieve changed records is described here, see
endpoint documentation below to see which endpoints support this and for further
details.

To initiate a changed-records request supply the parameter `changed_since` with
a timestamp of the last API requests.

| Parameter     | Data type                                                           | Description                                                                                                                           |
|---------------|---------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------|
| changed_since | [ISO 8601 date/time string](https://en.wikipedia.org/wiki/ISO_8601) | Request all records that have changed since this date/time. Leave blank to retrieve all records                                       |
| changed_id    | Integer                                                             | Optional. In the case where multiple records are changed within the same second, this is used to specify which record id to start at. |
|               |                                                                     |                                                                                                                                       |


The response headers will include information related to continuing to retrieve
changed records either immediately, or when ready to ingest more records.

| Header       | Description                                                                                    |
|--------------|------------------------------------------------------------------------------------------------|
| Link         | Links to the next and last pages.                                                              |
| Per-Page     | The maximum number of results on a page.                                                       |
| Total        | The total number of results.                                                                   |


As all responses from the API are paginated, a set maximum of results will be
returned and a link to the next page will be included in the response headers.
If the value for `Total` is less than `Per-Page` that indicates that there are
no more results to retrieve with the `next` link, and if used 0 records will be
returned. The `next` link may be saved for a future request to continue the
incremental loading of changed data.

# Errors

The API uses the following error codes:

Error Code | Meaning
---------- | -------
400 | Bad Request -- Your request is invalid.
401 | Unauthorized -- Your API key is wrong.
404 | Not Found -- The specified resource could not be found.
500 | Internal Server Error -- We had a problem with our server. Try again later.
503 | Service Unavailable -- We're temporarily offline for maintenance. Please try again later.

# Preparation for the next recruitment cycle (rollover)

During a given recruitment cycle, there will be a period when providers have two sets of courses to manage – one set of courses that are currently published for the current recruitment cycle, and unpublished courses being preparated for the next recruitment cycle. Additionally, the providers who deliver next year's courses may change, and they may have different campuses for the same courses. The point in time when the overlap starts is referred to as rollover, and typically happens in or around May.

To differentiate between entities from different recruitment cycles, each endpoint has a `<recruitment_cycle>` part in the URL. Additionally, the following entities have a `recruitment_cycle` attribute:

- course
- campus
- campus status

# Endpoints

## Courses

### Entity documentation

Parameter | Data type | Possible values | Description
--------- | --------- | --------------- | -----------
course_code | Text | 4-character strings | 4-character course code
start_month | ISO 8601 date/time string | | The month and year when the course starts
start_month_string | Text | January, February, etc | The month when the course starts as a string
name | Text | | Course title
copy_form_required | Text | 'Y' or 'N' |
profpost_flag | Text | "", "PF", "PG", "BO" | Maximum of 2-characters
program_type | Text | "SC", "SS", "TA", "SD", "HE" | Maximum of 2-characters
modular | Text | "", "M" | Maximum of 1-character
english | Integer | 1, 2, 3, 9 |
maths | Integer | 1, 2, 3, 9 |
science | Integer | 1, 2, 3, 9, null |
recruitment_cycle | Text || 4-character year
campus_statuses | An array of campus statuses | | See the campus status entity documentation below
subjects | An array of subjects | | See the subject entity documentation below
provider | Provider | A provider entity | See the provider entity documentation below
accrediting_provider | Provider | null or a provider entity | See the provider entity documentation below
age_range | Text | "P", "S", "M", "O" | Age of students targeted by this course.

#### Course codes

Course codes:

- are unique within a provider
- are not unique across providers
- are stable across rollover (i.e. by default, a course in a particular subject delivered by the same provider will have the same course code across different recruitment cycles)

### Get all courses

```shell
curl "https://manage-courses-backend.herokuapp.com/api/v1/2019/courses"
  -H "Authorization: Bearer your_api_key"
```

> The above command returns JSON structured like this:

```json
[
  {
    "course_code": "36B3",
    "start_month": "2019-09-01T00:00:00.000Z",
    "start_month_string": "September",
    "name": "Mathematics",
    "study_mode": "F",
    "copy_form_required": "Y",
    "profpost_flag": "PG",
    "program_type": "SD",
    "modular": "M",
    "english": 1,
    "maths": 3,
    "science": null,
    "qualification": 1,
    "recruitment_cycle": "2019",
    "age_range": "S",
    "campus_statuses": [
      {
        "campus_code": "-",
        "name": "Main Site",
        "vac_status": "F",
        "publish": "Y",
        "status": "R",
        "course_open_date": "2018-10-09 00:00:00",
        "recruitment_cycle": "2019"
      }
    ],
    "subjects": [
      {
        "subject_name": "Secondary",
        "subject_code": "05"
      },
      {
        "subject_name": "Mathematics",
        "subject_code": "G1"
      }
    ],
    "provider": {
      "institution_code": "2G9",
      "institution_name": "Outwood Institute of Education North",
      "institution_type": "Y",
      "accrediting_provider": "Y",
      "address1": "Sydney Russell School",
      "address2": "Parsloes Avenue",
      "address3": "Dagenham",
      "address4": "Essex",
      "postcode": "RM9 5QT"
    },
    "accrediting_provider": {
      "institution_code": "D86",
      "institution_name": "Durham University",
      "institution_type": "Y",
      "accrediting_provider": "Y"
    }
  },
  {
    ...
  }
]
```

This endpoint retrieves all courses.

#### HTTP Request

`GET https://manage-courses-backend.herokuapp.com/api/v1/<recruitment_cycle>/courses`

#### URL Parameters

Parameter | Description
--------- | -----------
recruitment_cycle | 4-character year (e.g. 2019 for 2019/20 courses)

### Get changed courses

This endpoint supports retrieving courses that have changed since the
specified point in time, see the [Retrieving Changed
Records](#retrieving-changed-records) section.

The returned results:

- match the structure of the [Get all courses](#get-all-courses) endpoint
- are sorted chronologically with the oldest update first
- are paginated with a page size of 100 (see the [pagination section](#pagination) for info about navigating pages)

A course is marked as changed (and hence included in this endpoint) if:

- the course itself has been changed
- the campus status has changed
- campus associations have changed
- subject associations have changed

#### HTTP Request

`GET https://manage-courses-backend.herokuapp.com/api/v1/<recruitment_cycle>/courses?changed_since=<iso-8601-timestamp>`

#### URL Parameters

| Parameter         | Description                                                         |
|-------------------|---------------------------------------------------------------------|
| recruitment_cycle | 4-character year (e.g. 2019 for 2019/20 courses)                    |
| changed_since     | [ISO 8601 date/time string](https://en.wikipedia.org/wiki/ISO_8601) |

## Campuses

### Entity documentation

Parameter | Data type | Possible values | Description
--------- | --------- | --------------- | -----------
campus_code | Text | A-Z, 0-9, "-" or "" | 1-character campus codes
name | Text | |
region_code | Text | 01 to 11 | 2-character string
recruitment_cycle | Text || 4-character year

<aside class="warning">
A single provider can have at most 37 campuses.
</aside>

## Campus statuses

### Entity documentation

Parameter | Data type | Possible values | Description
--------- | --------- | --------------- | -----------
campus_code | Text | A-Z, 0-9, "-", "" | 1-character campus codes
name | Text | |
vac_status | Text | |
publish | Text | |
status | Text | |
course_open_date | ISO 8601 date/time string | |
recruitment_cycle | Text || 4-character year

## Subjects

### Entity documentation

Parameter | Data type | Possible values | Description
--------- | --------- | --------------- | -----------
subject_code | Text | 2-character strings | 2-character subject codes
subject_name | Text | |

### Get all subjects

```shell
curl "https://manage-courses-backend.herokuapp.com/api/v1/2019/subjects"
  -H "Authorization: Bearer your_api_key"
```

> The above command returns JSON structured like this:

```json
[
  {
    "subject_name": "Chinese",
    "subject_code": "T1"
  },
  {
    ...
  }
]
```

This endpoint retrieves all subjects.

#### HTTP Request

`GET https://manage-courses-backend.herokuapp.com/api/v1/<recruitment_cycle>/subjects`

#### URL Parameters

Parameter | Description
--------- | -----------
recruitment_cycle | 4-character year (e.g. 2019 for 2019/20 courses)

## Providers

### Entity documentation

Parameter | Data type | Possible values | Description
--------- | --------- | --------------- | -----------
institution_code | Text | 3-character strings | 3-character UCAS institution code
institution_name | Text | | The institution's full-length marketing name
institution_type | Text | "Y", "B", "0", "O", null | The type of institution (whether it's a university, lead school/teaching school alliance or a SCITT)
accrediting_provider | Text | "Y" or "N" | Whether the provider can accredit courses or not
campuses | An array of campus || See the campus entity documentation above
address1 | Text || Address line 1
address2 | Text || Address line 2
address3 | Text || Town/City
address4 | Text || County
postcode | Text || Postcode
region_code | Text | 01 to 11 | 2-character string

### Get all providers

```shell
curl "https://manage-courses-backend.herokuapp.com/api/v1/2019/providers"
  -H "Authorization: Bearer your_api_key"
```

> The above command returns JSON structured like this:

```json
[
  {
    "institution_code": "P60",
    "institution_name": "University of Plymouth",
    "institution_type": "Y",
    "accrediting_provider": "Y",
    "address1": "Sydney Russell School",
    "address2": "Parsloes Avenue",
    "address3": "Dagenham",
    "address4": "Essex",
    "postcode": "RM9 5QT",
    "region_code": "01",
    "campuses": [
      {
        "campus_code": "",
        "name": "Main Site",
        "recruitment_cycle": "2019",
        "region_code": "01"
      }
    ]
  },
  {
    ...
  }
]
```

This endpoint retrieves all institutions.

#### HTTP Request

`GET https://manage-courses-backend.herokuapp.com/api/v1/<recruitment_cycle>/providers`

#### URL Parameters

Parameter | Description
--------- | -----------
recruitment_cycle | 4-character year (e.g. 2019 for 2019/20 courses)

### Get changed providers

This endpoint supports retrieving providers that have changed since the
specified point in time, see the [Retrieving Changed
Records](#retrieving-changed-records) section.

The returned results:

- matches the structure of the [Get all providers](#get-all-providers) endpoint
- are sorted chronologically with the oldest update first
- are paginated with a page size of 100 (see the [pagination section](#pagination) for info about navigating pages)

A provider is marked as changed (and hence included in this endpoint) if:

- the provider itself has been changed (including contact data changes)
- any of the associated campuses has changed
- campus associations have changed

#### HTTP Request

`GET https://manage-courses-backend.herokuapp.com/api/v1/<recruitment_cycle>/providers?changed_since=<iso-8601-timestamp>`

#### URL Parameters

Parameter | Description
--------- | -----------
recruitment_cycle | 4-character year (e.g. 2019 for 2019/20 courses)
changed_since | [ISO 8601 date/time string](https://en.wikipedia.org/wiki/ISO_8601)
