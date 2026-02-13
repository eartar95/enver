@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GL Journal Item Projection'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZEA_C_JOURNAL_ITEM
  as projection on ZEA_I_JOURNAL_ITEM
{
  key Uuid,
  key Bschl,
      @Semantics.amount.currencyCode: 'Waers'
      Wrbtr,
      Waers,
      Sgtxt,
      Hkont,
      Kostl,
      Prctr,
      @Semantics.user.createdBy: true
      ItemCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      ItemCreatedAt,
      @Semantics.user.lastChangedBy: true
      ItemLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      ItemLastChangedAt,
      _Header : redirected to parent ZEA_C_JOURNAL
}
