@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Document Posting Header ROOT'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZEA_I_DOCPOST as select from zea_docpost_hdr
composition [1..*] of ZEA_I_DOCPOST_ITM as _Items
{
    key guid as Guid,
    company_code as CompanyCode,
    document_date as DocumentDate,
    posting_date as PostingDate,
    document_type as DocumentType,
    accounting_doc as AccountingDoc,
    fiscal_year as FiscalYear,
    status as Status,
    message_text as MessageText,
    created_at as CreatedAt,
    created_by as CreatedBy,
    changed_at as ChangedAt,
    changed_by as ChangedBy,
    _Items
}
