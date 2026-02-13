//@AbapCatalog.sqlViewName: ''
//@AbapCatalog.compiler.compareFilter: true
//@AbapCatalog.preserveKey: true



@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ZFI - Statement Line (Clean Params)'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZFI_I_StmtLine
  with parameters
    p_source_ledger : fins_ledger,
    p_bukrs         : bukrs,
    p_budat    : budat,
    p_bldat    : bldat

as select distinct from  I_JournalEntryItem as it
    
  inner join I_OperationalAcctgDocItem as op
    on  op.CompanyCode            = it.CompanyCode
    and op.FiscalYear             = it.FiscalYear
    and op.AccountingDocument     = it.AccountingDocument
    and op.AccountingDocumentItem = cast(
          substring( cast( it.LedgerGLLineItem as abap.char(6) ), 4, 3 )
          as abap.numc(3)
        )
 
   
  left outer join I_GLAccountText as gl_racct
    on  gl_racct.ChartOfAccounts = it.ChartOfAccounts
    and gl_racct.GLAccount       = it.GLAccount
    and gl_racct.Language        = $session.system_language

  left outer join I_GLAccountText as gl_gkont
    on  gl_gkont.ChartOfAccounts = it.ChartOfAccounts
    and gl_gkont.GLAccount       = it.OffsettingAccount
    and gl_gkont.Language        = $session.system_language

  left outer join I_Customer as cust
    on cust.Customer = it.Customer

  left outer join I_Supplier as supp
    on supp.Supplier = it.Supplier

  left outer join I_Customer as cust_gkont
    on cust_gkont.Customer = it.OffsettingAccount

  left outer join I_Supplier as supp_gkont
    on supp_gkont.Supplier = it.OffsettingAccount

{
  it.CompanyCode          as bukrs,
  it.FiscalYear           as gjahr,
  it.TransactionCurrency  as rwcur,

  it.OffsettingAccount    as gkont,
  case
    when it.OffsettingAccountType = 'D' then cust_gkont.OrganizationBPName1
    when it.OffsettingAccountType = 'K' then supp_gkont.OrganizationBPName1
    else gl_gkont.GLAccountLongName
  end                     as gkont_name,

  it.PostingDate          as budat,
  it.DocumentDate         as bldat,

  op.DueCalculationBaseDate as zfbdt,
  op.NetDueDate             as faedt,

  it.AccountingDocument   as belnr,
  it.GLAccount            as racct,
  gl_racct.GLAccountLongName as txt50,

  case
    when it.FinancialAccountType = 'K' then it.Supplier
    when it.FinancialAccountType = 'D' then it.Customer
    else it.GLAccount
  end                     as kunnr,

  case
    when it.FinancialAccountType = 'D' then cust.OrganizationBPName1
    when it.FinancialAccountType = 'K' then supp.OrganizationBPName1
    else gl_racct.GLAccountLongName
  end                     as hesap_tanimi,

  case
    when it.FinancialAccountType = 'D' then cust.OrganizationBPName2
    when it.FinancialAccountType = 'K' then supp.OrganizationBPName2
    else cast( '' as abap.char(35) )
  end                     as sube_adi,

  it.DocumentItemText     as sgtxt,
  it.SpecialGLCode        as umskz,

  it.CompanyCodeCurrency  as toplam_pb_tr,
  cast( 'EUR' as abap.cuky ) as toplam_pb_eur,
  cast( 'USD' as abap.cuky ) as toplam_pb_usd,

  cast(
    case when it.DebitCreditCode = 'S'
      then cast( it.AmountInCompanyCodeCurrency as abap.dec(23,2) )
      else cast( 0 as abap.dec(23,2) )
    end as abap.dec(23,2)
  ) as borc_tr,
 
  cast(
    case when it.DebitCreditCode <> 'S'
      then cast( it.AmountInCompanyCodeCurrency as abap.dec(23,2) )
      else cast( 0 as abap.dec(23,2) )
    end as abap.dec(23,2)
  ) as alacak_tr,
 
  cast( it.AmountInCompanyCodeCurrency as abap.dec(23,2) ) as toplam_tr,

//   cast( 0 as abap.dec(23,2) ) as toplam_tr,

  /* EUR */
//  cast(
//    case
//      when it.TransactionCurrency = 'EUR' then cast( it.AmountInTransactionCurrency as abap.dec(23,2) )
//      when it.GlobalCurrency      = 'EUR' then cast( it.AmountInGlobalCurrency      as abap.dec(23,2) )
//      when it.FunctionalCurrency  = 'EUR' then cast( it.AmountInFunctionalCurrency  as abap.dec(23,2) )
//      when it.CompanyCodeCurrency = 'EUR' then cast( it.AmountInCompanyCodeCurrency as abap.dec(23,2) )
//      else cast( 0 as abap.dec(23,2) )
//    end
//  as abap.dec(23,2) ) as toplam_eur,
  
  cast( it.AmountInGlobalCurrency      as abap.dec(23,2) ) as toplam_eur,



//  cast(
//    case when it.DebitCreditCode = 'S' then
//      case
//        when it.TransactionCurrency = 'EUR' then cast( it.AmountInTransactionCurrency as abap.dec(23,2) )
//        when it.GlobalCurrency      = 'EUR' then cast( it.AmountInGlobalCurrency      as abap.dec(23,2) )
//        when it.FunctionalCurrency  = 'EUR' then cast( it.AmountInFunctionalCurrency  as abap.dec(23,2) )
//        when it.CompanyCodeCurrency = 'EUR' then cast( it.AmountInCompanyCodeCurrency as abap.dec(23,2) )
//        else cast( 0 as abap.dec(23,2) )
//      end
//    else cast( 0 as abap.dec(23,2) ) end
//  as abap.dec(23,2) ) as borc_eur,
  
    cast(
    case when it.DebitCreditCode = 'S' then
    cast( it.AmountInGlobalCurrency      as abap.dec(23,2) )
         end
    as abap.dec(23,2) ) as borc_eur,

//  cast(
//    case when it.DebitCreditCode <> 'S' then
//      case
//        when it.TransactionCurrency = 'EUR' then cast( it.AmountInTransactionCurrency as abap.dec(23,2) )
//        when it.GlobalCurrency      = 'EUR' then cast( it.AmountInGlobalCurrency      as abap.dec(23,2) )
//        when it.FunctionalCurrency  = 'EUR' then cast( it.AmountInFunctionalCurrency  as abap.dec(23,2) )
//        when it.CompanyCodeCurrency = 'EUR' then cast( it.AmountInCompanyCodeCurrency as abap.dec(23,2) )
//        else cast( 0 as abap.dec(23,2) )
//      end
//    else cast( 0 as abap.dec(23,2) ) end
//  as abap.dec(23,2) ) as alacak_eur,

    cast(
    case when it.DebitCreditCode <> 'S' then
    cast( it.AmountInGlobalCurrency      as abap.dec(23,2) )
         end
    as abap.dec(23,2) ) as alacak_eur,

  /* USD */
//  cast(
//    case
//      when it.TransactionCurrency = 'USD' then cast( it.AmountInTransactionCurrency as abap.dec(23,2) )
//      when it.GlobalCurrency      = 'USD' then cast( it.AmountInGlobalCurrency      as abap.dec(23,2) )
//      when it.FunctionalCurrency  = 'USD' then cast( it.AmountInFunctionalCurrency  as abap.dec(23,2) )
//      when it.CompanyCodeCurrency = 'USD' then cast( it.AmountInCompanyCodeCurrency as abap.dec(23,2) )
//      else cast( 0 as abap.dec(23,2) )
//    end
//  as abap.dec(23,2) ) as toplam_usd,

  cast( it.AmountInFreeDefinedCurrency1      as abap.dec(23,2) ) as toplam_usd,

//  cast(
//    case when it.DebitCreditCode = 'S' then
//      case
//        when it.TransactionCurrency = 'USD' then cast( it.AmountInTransactionCurrency as abap.dec(23,2) )
//        when it.GlobalCurrency      = 'USD' then cast( it.AmountInGlobalCurrency      as abap.dec(23,2) )
//        when it.FunctionalCurrency  = 'USD' then cast( it.AmountInFunctionalCurrency  as abap.dec(23,2) )
//        when it.CompanyCodeCurrency = 'USD' then cast( it.AmountInCompanyCodeCurrency as abap.dec(23,2) )
//        else cast( 0 as abap.dec(23,2) )
//      end
//    else cast( 0 as abap.dec(23,2) ) end
//  as abap.dec(23,2) ) as borc_usd,

  cast(
    case when it.DebitCreditCode = 'S' then
    cast( it.AmountInFreeDefinedCurrency1      as abap.dec(23,2) )
          end
  as abap.dec(23,2) ) as borc_usd,

//  cast(
//    case when it.DebitCreditCode <> 'S' then
//      case
//        when it.TransactionCurrency = 'USD' then cast( it.AmountInTransactionCurrency as abap.dec(23,2) )
//        when it.GlobalCurrency      = 'USD' then cast( it.AmountInGlobalCurrency      as abap.dec(23,2) )
//        when it.FunctionalCurrency  = 'USD' then cast( it.AmountInFunctionalCurrency  as abap.dec(23,2) )
//        when it.CompanyCodeCurrency = 'USD' then cast( it.AmountInCompanyCodeCurrency as abap.dec(23,2) )
//        else cast( 0 as abap.dec(23,2) )
//      end
//    else cast( 0 as abap.dec(23,2) ) end
//  as abap.dec(23,2) ) as alacak_usd

    cast(
    case when it.DebitCreditCode <> 'S' then
    cast( it.AmountInFreeDefinedCurrency1      as abap.dec(23,2) )
          end
  as abap.dec(23,2) ) as alacak_usd
 
}


where
      it.SourceLedger = $parameters.p_source_ledger
  and it.CompanyCode  = $parameters.p_bukrs
  and ( op.FinancialAccountType = 'K' or op.FinancialAccountType = 'D' ) 
  and it.FiscalYear <=  substring( $parameters.p_budat, 1, 4 );
  
//  and it.PostingDate  <= $parameters.p_budat_high
//
//  and ( $parameters.p_racct = '' or it.GLAccount     = $parameters.p_racct )
//  and ( $parameters.p_kunnr = '' or it.Customer      = $parameters.p_kunnr )
//  and ( $parameters.p_lifnr = '' or it.Supplier      = $parameters.p_lifnr )
//  and ( $parameters.p_umskz = '' or it.SpecialGLCode = $parameters.p_umskz );
