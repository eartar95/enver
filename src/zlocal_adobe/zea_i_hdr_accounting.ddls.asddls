@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Form Header Structure'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@ObjectModel.supportedCapabilities: [ #OUTPUT_FORM_DATA_PROVIDER ]
@ObjectModel.modelingPattern: #OUTPUT_FORM_DATA_PROVIDER
define view entity ZEA_I_HDR_ACCOUNTING
  as select from I_JournalEntry as H
  association [1..*] to ZEA_I_ITEM_ACCOUNTING as _Items on  $projection.CompanyCode        = _Items.CompanyCode
                                                        and $projection.FiscalYear         = _Items.FiscalYear
                                                        and $projection.AccountingDocument = _Items.AccountingDocument
{
  key H.CompanyCode,
  key H.FiscalYear,
  key H.AccountingDocument,
      H.AccountingDocumentType,
      H.DocumentDate,
      H.PostingDate,
      H.FiscalPeriod,
      _Items

}
