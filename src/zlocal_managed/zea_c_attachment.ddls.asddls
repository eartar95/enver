@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Attachment Consumption'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZEA_C_ATTACHMENT as projection on ZEA_I_ATTACHMENT
{
    key AttachId,
    Id,
    Comments,
        @Semantics.largeObject:{
      mimeType : 'Mimetype',
      fileName: 'Filename',
      contentDispositionPreference: #INLINE
    }
    Attachment,
    Mimetype,
    Filename,
    _Student.Lastchangedat as LastChangedat,
    _Student : redirected to parent ZEA_C_STUDENT
}
