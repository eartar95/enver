@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Student Interface'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Metadata.allowExtensions: true

define root view entity ZEA_I_STUDENT
  as select from zea_student
  composition[0..*] of ZEA_I_ACADEMIC as _academicres
  association[0..1] to ZEA_I_GENDER as _gender on $projection.Gender = _gender.Value //ortak
                    //birleşim(association to parent student olmalı academic interface)
  composition[1..*] of ZEA_I_ATTACHMENT as _Attachments
{

  
  key id                 as Id,
      firstname          as Firstname,
      lastname           as Lastname,
      concat_with_space( firstname, lastname, 1) as Fullname,
      age                as Age,
      course             as Course,
      courseduration     as Courseduration,
      status             as Status,
      gender             as Gender,
      dob                as Dob,
      lastchangedat      as Lastchangedat,
      locallastchangedat as Locallastchangedat,
      _gender,
      _gender.Description as Genderdesc,
      _academicres,
      _Attachments

}
