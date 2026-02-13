@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GL Journal Entry Item'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}
define view entity ZEA_I_JOURNAL_ITEM
  as select from zea_journal_i
  association to parent ZEA_I_JOURNAL as _Header on $projection.Uuid = _Header.Uuid
{
  key uuid                       as Uuid,
  key bschl                      as Bschl,
      @Semantics.amount.currencyCode: 'Waers'
      wrbtr                      as Wrbtr,
      _Header.Waers        as Waers,
      sgtxt                      as Sgtxt,
      hkont                      as Hkont,
      kostl                      as Kostl,
      prctr                      as Prctr,
      @Semantics.user.createdBy: true
      item_created_by            as ItemCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      item_created_at            as ItemCreatedAt,
      @Semantics.user.lastChangedBy: true
      item_last_changed_by       as ItemLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      item_last_changed_at       as ItemLastChangedAt,
      _Header
}
