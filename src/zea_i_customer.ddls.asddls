@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Customer CDS'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZEA_I_CUSTOMER as select from I_JournalEntryItem  as i_customer
{
    key SourceLedger as sourceledger,
    key CompanyCode as bukrs,
    key FiscalYear as gjahr,
    key AccountingDocument as belnr,
    key LedgerGLLineItem as buzei,
    key Ledger as ledger,    
    Customer as customer,
    AlternativeGLAccount as hesap,
    @Semantics.amount.currencyCode: 'waers'
    AmountInTransactionCurrency as dmbtr,
    TransactionCurrency as waers,
    SpecialGLCode as umskz,
    PostingDate as budat,
   
    case 
        when ( AmountInTransactionCurrency > 5000 and AmountInTransactionCurrency < 10000) then '2'
        when ( AmountInTransactionCurrency >= 10000 ) then '3'
        else '1'
    end as color,
    
    
    
    
   ( cast( ' ' as abap_boolean ) ) as devir_bakiye_dahil
//    cast (
//        case
//      when PostingDate is not null
//        then 'X'
//      else ''
//    end as abap_boolean ) as devir_bakiye_dahil 
    
    
}

where Customer is not initial and
//      AlternativeGLAccount like '0120%' and
      SourceLedger = '0L' and
      Ledger = '0L'

