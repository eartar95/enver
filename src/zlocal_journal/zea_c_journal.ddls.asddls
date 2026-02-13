@EndUserText.label: 'GL Journal Entry Projection'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZEA_C_JOURNAL
  provider contract transactional_query
  as projection on ZEA_I_JOURNAL
{
  key Uuid,
      belnr,
      Bukrs,
      Gjahr,
      Waers,
      Bldat,
      Budat,
      Bktxt,
      @Semantics.user.createdBy: true
      CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      CreatedAt,
      @Semantics.user.lastChangedBy: true
      LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocalLastChangedAt,
      _Item : redirected to composition child ZEA_C_JOURNAL_ITEM 
}
