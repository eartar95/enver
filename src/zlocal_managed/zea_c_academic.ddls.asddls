@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Academic Consuption'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZEA_C_ACADEMIC 
as projection on ZEA_I_ACADEMIC
{
    key Id,
    key Course,
    key Semester,
    course_desc,
    sem_desc,
    Semresult,
    semres_desc,
    /* Associations */
    _student : redirected to parent ZEA_C_STUDENT
}
