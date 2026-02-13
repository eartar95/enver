@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root projection'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZEA_C_DOCPOST 
    provider contract transactional_query as projection on ZEA_I_DOCPOST
{
    key Guid,
    CompanyCode,
    DocumentDate,
    PostingDate,
    DocumentType,
    AccountingDoc,
    FiscalYear,
    Status,
    MessageText,
    CreatedAt,
    CreatedBy,
    ChangedAt,
    ChangedBy,
    /* Associations */
    _Items : redirected to composition child ZEA_C_DOCPOST_ITM
}
