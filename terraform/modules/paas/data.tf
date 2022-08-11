data cloudfoundry_domain london_cloudapps_digital {
  name = "london.cloudapps.digital"
}

data cloudfoundry_domain api_publish_service_gov_uk {
  name = "api.publish-teacher-training-courses.service.gov.uk"
}

data cloudfoundry_domain publish_service_gov_uk {
  name = "publish-teacher-training-courses.service.gov.uk"
}

data cloudfoundry_domain find_service_gov_uk {
  name = "find-postgraduate-teacher-training.service.gov.uk"
}

data cloudfoundry_org org {
  name = "dfe"
}

data cloudfoundry_space space {
  name = var.cf_space
  org  = data.cloudfoundry_org.org.id
}

data cloudfoundry_service postgres {
  name = "postgres"
}

data cloudfoundry_service redis {
  name = "redis"
}
