@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ZFI - Statement Final Dataset'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZFI_C_Statement
  with parameters
    p_source_ledger : fins_ledger,
    p_bukrs         : bukrs,
    p_budat         : budat,
    p_bldat         : bldat
  //    p_budat_low     : budat,
  //    p_budat_high    : budat,
  //    p_racct         : zfi_de_racct,
  //    p_kunnr         : kunnr,
  //    p_lifnr         : lifnr,
  //    p_umskz         : zfi_de_umskz
  as

  /* ============================================================
     1) KALEM (İLK SELECT) -> signature'ı bu branch belirler
     ============================================================ */
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
              ) as l
{
      /* KEY */
  key cast(
        concat(
          concat( concat( l.kunnr, '_' ), '20' ),
          concat( concat( '_', l.belnr ), concat( '_', l.racct ) )
        ) as abap.char(60)
      )                                as RecordKey,

      /* Kimlik */
      l.kunnr                          as kunnr,
      cast( 20 as abap.int4 )          as row_type,
      cast( 'Kalem' as abap.char(20) ) as row_text,

      /* Kalem alanları */
      l.bukrs                          as bukrs,
      l.gjahr                          as gjahr,
      l.rwcur                          as rwcur,
      l.gkont                          as gkont,
      l.gkont_name                     as gkont_name,
      l.budat                          as budat,
      l.bldat                          as bldat,
      l.zfbdt                          as zfbdt,
      l.faedt                          as faedt,
      l.belnr                          as belnr,
      l.racct                          as racct,
      l.txt50                          as txt50,
      l.hesap_tanimi                   as hesap_tanimi,
      l.sube_adi                       as sube_adi,
      l.sgtxt                          as sgtxt,
      l.umskz                          as umskz,

      /* Tutarlar */
      l.borc_tr,
      l.alacak_tr,
      l.toplam_tr,
      l.toplam_pb_tr,
      l.borc_eur,
      l.alacak_eur,
      l.toplam_eur,
      l.toplam_pb_eur,
      l.borc_usd,
      l.alacak_usd,
      l.toplam_usd,
      l.toplam_pb_usd
}
//where l.budat between $parameters.p_budat_low and $parameters.p_budat_high

union all

/* ============================================================
   2) DEVIR -> aynı kolonlar, kalem alanları dummy
   ============================================================ */
select from ZFI_I_StmtAg(
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
            ) as d
{
  key cast( concat( concat( d.kunnr, '_' ), '10' ) as abap.char(60) ) as RecordKey,

      d.kunnr                                                         as kunnr,
      d.row_type                                                      as row_type,
      d.row_text                                                      as row_text,

      /* Kalem alanları: dummy */
      cast( $parameters.p_bukrs as bukrs )                            as bukrs,
      cast( '' as gjahr )                                             as gjahr,
      cast( '' as abap.cuky )                                         as rwcur,
      cast( '' as abap.char(10) )                                     as gkont,
      cast( '' as abap.char(50) )                                     as gkont_name,
      cast( '00000000' as abap.dats )                                 as budat,
      cast( '00000000' as abap.dats )                                 as bldat,
      cast( '00000000' as abap.dats )                                 as zfbdt,
      cast( '00000000' as abap.dats )                                 as faedt,
      cast( '' as abap.char(10) )                                     as belnr,
      cast( '' as abap.char(10) )                                     as racct,
      cast( '' as abap.char(50) )                                     as txt50,
      cast( '' as abap.char(80) )                                     as hesap_tanimi,
      cast( '' as abap.char(35) )                                     as sube_adi,
      cast( '' as abap.char(50) )                                     as sgtxt,
      cast( '' as abap.char(1) )                                      as umskz,

      /* Tutarlar: agg'den */
      d.borc_tr,
      d.alacak_tr,
      d.toplam_tr,
      d.toplam_pb_tr,
      d.borc_eur,
      d.alacak_eur,
      d.toplam_eur,
      d.toplam_pb_eur,
      d.borc_usd,
      d.alacak_usd,
      d.toplam_usd,
      d.toplam_pb_usd


}
where
  d.row_type = 10

union all

/* ============================================================
   3) TOPLAM -> aynı kolonlar, kalem alanları dummy
   ============================================================ */
select from ZFI_I_StmtAg(
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
            ) as t
{
  key cast( concat( concat( t.kunnr, '_' ), '30' ) as abap.char(60) ) as RecordKey,

      t.kunnr                                                         as kunnr,
      t.row_type                                                      as row_type,
      t.row_text                                                      as row_text,

      /* Kalem alanları: dummy */
      cast( $parameters.p_bukrs as bukrs )                            as bukrs,
      cast( '' as gjahr )                                             as gjahr,
      cast( '' as abap.cuky )                                         as rwcur,
      cast( '' as abap.char(10) )                                     as gkont,
      cast( '' as abap.char(50) )                                     as gkont_name,
      cast( '00000000' as abap.dats )                                 as budat,
      cast( '00000000' as abap.dats )                                 as bldat,
      cast( '00000000' as abap.dats )                                 as zfbdt,
      cast( '00000000' as abap.dats )                                 as faedt,
      cast( '' as abap.char(10) )                                     as belnr,
      cast( '' as abap.char(10) )                                     as racct,
      cast( '' as abap.char(50) )                                     as txt50,
      cast( '' as abap.char(80) )                                     as hesap_tanimi,
      cast( '' as abap.char(35) )                                     as sube_adi,
      cast( '' as abap.char(50) )                                     as sgtxt,
      cast( '' as abap.char(1) )                                      as umskz,

      /* Tutarlar: agg'den */
      t.borc_tr,
      t.alacak_tr,
      t.toplam_tr,
      t.toplam_pb_tr,
      t.borc_eur,
      t.alacak_eur,
      t.toplam_eur,
      t.toplam_pb_eur,
      t.borc_usd,
      t.alacak_usd,
      t.toplam_usd,
      t.toplam_pb_usd

}
where
  t.row_type = 30;
