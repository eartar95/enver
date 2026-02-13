@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ZFI - Statement Aggregation (Clean Params)'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZFI_I_StmtAg
  with parameters
    p_source_ledger : fins_ledger,
    p_bukrs         : bukrs,
    p_budat         : budat,
    p_bldat         : bldat

  as

  select from ZFI_I_StmtLine(
              p_source_ledger: $parameters.p_source_ledger,
              p_bukrs        : $parameters.p_bukrs,
              p_budat        : $parameters.p_budat,
              p_bldat        : $parameters.p_bldat

              ) as it
{
  key it.kunnr                         as kunnr,
  key cast( 10 as abap.int4 )          as row_type,
      cast( 'Devir' as abap.char(20) ) as row_text,

      cast( 0 as abap.dec(23,2) )      as alacak_tr,
      cast( 0 as abap.dec(23,2) )      as borc_tr,
      sum( it.toplam_tr )              as toplam_tr,
      cast( 'TRY' as abap.cuky )       as toplam_pb_tr,

      cast( 0 as abap.dec(23,2) )      as alacak_eur,
      cast( 0 as abap.dec(23,2) )      as borc_eur,
      sum( it.toplam_eur )             as toplam_eur,
      cast( 'EUR' as abap.cuky )       as toplam_pb_eur,

      cast( 0 as abap.dec(23,2) )      as alacak_usd,
      cast( 0 as abap.dec(23,2) )      as borc_usd,
      sum( it.toplam_usd )             as toplam_usd,
      cast( 'USD' as abap.cuky )       as toplam_pb_usd

}
where budat <= $parameters.p_budat or
      bldat <= $parameters.p_bldat
group by
  it.kunnr

union all

select from ZFI_I_StmtLine(
            p_source_ledger: $parameters.p_source_ledger,
            p_bukrs        : $parameters.p_bukrs,
            p_budat        : $parameters.p_budat,
            p_bldat        : $parameters.p_bldat
            //  p_budat_low    : $parameters.p_budat_low,
            //  p_budat_high   : $parameters.p_budat_high,
            //  p_racct        : $parameters.p_racct,
            //  p_kunnr        : $parameters.p_kunnr,
            //  p_lifnr        : $parameters.p_lifnr,
            //  p_umskz        : $parameters.p_umskz
            ) as it2
{
  key it2.kunnr                         as kunnr,
  key cast( 30 as abap.int4 )           as row_type,
      cast( 'Toplam' as abap.char(20) ) as row_text,

      cast( 0 as abap.dec(23,2) )       as alacak_tr,
      cast( 0 as abap.dec(23,2) )       as borc_tr,
      sum( it2.toplam_tr )              as toplam_tr,
      cast( 'TRY' as abap.cuky )        as toplam_pb_tr,

      cast( 0 as abap.dec(23,2) )       as alacak_eur,
      cast( 0 as abap.dec(23,2) )       as borc_eur,
      sum( it2.toplam_eur )             as toplam_eur,
      cast( 'EUR' as abap.cuky )        as toplam_pb_eur,

      cast( 0 as abap.dec(23,2) )       as alacak_usd,
      cast( 0 as abap.dec(23,2) )       as borc_usd,
      sum( it2.toplam_usd )             as toplam_usd,
      cast( 'USD' as abap.cuky )        as toplam_pb_usd

}
group by
  it2.kunnr;
