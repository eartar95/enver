@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Attachment Interface'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZEA_I_ATTACHMENT as select from zea_attachment
association to parent ZEA_I_STUDENT as _Student
on $projection.Id = _Student.Id
{
    key attach_id as AttachId,
    id as Id,
    comments as Comments,
    @Semantics.largeObject:{
      mimeType : 'Mimetype',
      fileName: 'Filename',
      contentDispositionPreference: #INLINE
    }
    attachment as Attachment,
    mimetype as Mimetype,
    filename as Filename,
    _Student.Lastchangedat as LastChangedat,
    _Student
}
