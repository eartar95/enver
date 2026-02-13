//@AbapCatalog.sqlViewName: ''
//@AbapCatalog.compiler.compareFilter: true
//@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Document Posting Item'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZEA_I_DOCPOST_ITM
  as select from zea_docpost_itm
  association to parent ZEA_I_DOCPOST as _Header on $projection.Guid = _Header.Guid
{
  key guid          as Guid,
  key item_no       as ItemNo,
      gl_account    as GLAccount,
      @Semantics.amount.currencyCode: 'Currency'
      amount        as Amount,
      currency      as Currency,
      drcr          as DebitCreaditCode,
      cost_center   as CostCenter,
      profit_center as ProfitCenter,
      _Header

}
