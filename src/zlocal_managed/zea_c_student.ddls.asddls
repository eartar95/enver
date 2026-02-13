@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Student Consumption'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZEA_C_STUDENT
provider contract transactional_query
as projection on ZEA_I_STUDENT as Student

{
    key Id,
    Firstname,
    Lastname,
    Fullname,
    Age,
    Course,
    Courseduration,
    Status,
    Gender,
    Genderdesc,
    Dob,
    Lastchangedat,
    Locallastchangedat,
   _academicres : redirected to composition child ZEA_C_ACADEMIC,
   @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZEA_CL_CALCULATE'
   @EndUserText.label: 'Total Course Duration'
   virtual TotalDuration : abap.int4,
   _Attachments : redirected to composition child ZEA_C_ATTACHMENT
} 
