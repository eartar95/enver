@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GL Journal Entry'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZEA_I_JOURNAL
  as select from ZEA_JOURNAL_H
  composition [0..*] of zea_i_journal_item as _Item
{
  key uuid                  as Uuid,
      bukrs                 as Bukrs,
      gjahr                 as Gjahr,
      belnr                 as Belnr,
      waers                 as Waers,
      bldat                 as Bldat,
      budat                 as Budat,
      bktxt                 as Bktxt,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      _Item
}
