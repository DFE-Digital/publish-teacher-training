class CreateGIASEstablishmentsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :gias_establishment do |t|
      t.text :urn
      t.text :name
      t.text :postcode

      # EstablishmentNumber
      # EstablishmentName
      # TypeOfEstablishment (code)
      # TypeOfEstablishment (name)
      # EstablishmentTypeGroup (code)
      # EstablishmentTypeGroup (name)
      # EstablishmentStatus (code)
      # EstablishmentStatus (name)
      # ReasonEstablishmentOpened (code)
      # ReasonEstablishmentOpened (name)
      # OpenDate
      # ReasonEstablishmentClosed (code)
      # ReasonEstablishmentClosed (name)
      # CloseDate
      # PhaseOfEducation (code)
      # PhaseOfEducation (name)
      # StatutoryLowAge
      # StatutoryHighAge
      # Boarders (code)
      # Boarders (name)
      # NurseryProvision (name)
      # OfficialSixthForm (code)
      # OfficialSixthForm (name)
      # Gender (code)
      # Gender (name)
      # ReligiousCharacter (code)
      # ReligiousCharacter (name)
      # ReligiousEthos (name)
      # Diocese (code)
      # Diocese (name)
      # AdmissionsPolicy (code)
      # AdmissionsPolicy (name)
      # SchoolCapacity
      # SpecialClasses (code)
      # SpecialClasses (name)
      # CensusDate
      # NumberOfPupils
      # NumberOfBoys
      # NumberOfGirls
      # PercentageFSM
      # TrustSchoolFlag (code)
      # TrustSchoolFlag (name)
      # Trusts (code)
      # Trusts (name)
      # SchoolSponsorFlag (name)
      # SchoolSponsors (name)
      # FederationFlag (name)
      # Federations (code)
      # Federations (name)
      # UKPRN
      # FEHEIdentifier
      # FurtherEducationType (name)
      # OfstedLastInsp
      # OfstedSpecialMeasures (code)
      # OfstedSpecialMeasures (name)
      # LastChangedDate
      # Street
      # Locality
      # Address3
      # Town
      # County (name)
      # Postcode
      # SchoolWebsite
      # TelephoneNum
      # HeadTitle (name)
      # HeadFirstName
      # HeadLastName
      # HeadPreferredJobTitle
      # BSOInspectorateName (name)
      # InspectorateReport
      # DateOfLastInspectionVisit
      # NextInspectionVisit
      # TeenMoth (name)
      # TeenMothPlaces
      # CCF (name)
      # SENPRU (name)
      # EBD (name)
      # PlacesPRU
      # FTProv (name)
      # EdByOther (name)
      # Section41Approved (name)
      # SEN1 (name)
      # SEN2 (name)
      # SEN3 (name)
      # SEN4 (name)
      # SEN5 (name)
      # SEN6 (name)
      # SEN7 (name)
      # SEN8 (name)
      # SEN9 (name)
      # SEN10 (name)
      # SEN11 (name)
      # SEN12 (name)
      # SEN13 (name)
      # TypeOfResourcedProvision (name)
      # ResourcedProvisionOnRoll
      # ResourcedProvisionCapacity
      # SenUnitOnRoll
      # SenUnitCapacity
      # GOR (code)
      # GOR (name)
      # DistrictAdministrative (code)
      # DistrictAdministrative (name)
      # AdministrativeWard (code)
      # AdministrativeWard (name)
      # ParliamentaryConstituency (code)
      # ParliamentaryConstituency (name)
      # UrbanRural (code)
      # UrbanRural (name)
      # GSSLACode (name)
      # Easting
      # Northing
      # CensusAreaStatisticWard (name)
      # MSOA (name)
      # LSOA (name)
      # InspectorateName (name)
      # SENStat
      # SENNoStat
      # BoardingEstablishment (name)
      # PropsName
      # PreviousLA (code)
      # PreviousLA (name)
      # PreviousEstablishmentNumber
      # OfstedRating (name)
      # RSCRegion (name)
      # Country (name)
      # UPRN
      # SiteName
      # MSOA (code)
      # LSOA (code)
    end
  end
end
