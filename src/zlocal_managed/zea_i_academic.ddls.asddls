@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view for Academic Result'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

define view entity ZEA_I_ACADEMIC
  as select from zea_academic
  association to parent ZEA_I_STUDENT as _student on $projection.Id = _student.Id
  association to ZEA_I_COURSE         as _course  on $projection.Course = _course.Value
  association to ZEA_I_SEM            as _sem     on $projection.Semester = _sem.Value
  association to ZEA_I_SEMRES         as _semres  on $projection.Semresult = _semres.Value
{
  key id                  as Id,
  key course              as Course,
  key semester            as Semester,
      _course.Description as course_desc,
      _sem.Description    as sem_desc,
      semresult           as Semresult,
      _semres.Description as semres_desc,
      _student
}
