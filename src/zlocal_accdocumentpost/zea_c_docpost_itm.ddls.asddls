@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Item projection'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZEA_C_DOCPOST_ITM as projection on ZEA_I_DOCPOST_ITM
{
    key Guid,
    key ItemNo,
    GLAccount,
    @Semantics.amount.currencyCode: 'Currency'
    Amount,
    Currency,
    DebitCreaditCode,
    CostCenter,
    ProfitCenter,
    /* Associations */
    _Header : redirected to parent ZEA_C_DOCPOST
}
