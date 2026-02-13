
CLASS lhc_ticker_ea DEFINITION INHERITING FROM cl_abap_behavior_handler.

PUBLIC SECTION.
    CLASS-DATA: gt_log  TYPE STANDARD TABLE OF zlcl_t_kripto.

  PRIVATE SECTION.

  " Seçili kayıtların anahtarlarını tutacak iç tablo
  TYPES: BEGIN OF ty_invoice_key,
            tickerId type zlcl_de_ticker,
         END OF ty_invoice_key.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR ticker RESULT result.

    METHODS read FOR READ
      IMPORTING keys FOR READ ticker RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK ticker.

    METHODS savelog FOR MODIFY
      IMPORTING keys FOR ACTION ticker~savelog RESULT result.

ENDCLASS.

CLASS lhc_ticker_ea IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD savelog.

    DATA: ls_log LIKE LINE OF gt_log.

    "Seçili kayıtların anahtarlarını içeren tablo
    DATA: lt_keys TYPE TABLE OF ty_invoice_key. " Burada manual key yapısını kullan
    DATA: lv_returnmsg  TYPE string.

    "Gelen keys parametresini al
    lt_keys = corresponding #( keys ).

    loop at lt_keys into data(ls_key).
        lv_returnmsg = ls_key-tickerId && ' tickerı seçildi'.
          APPEND VALUE #(   %msg = new_message_with_text(
                            severity = if_abap_behv_message=>severity-success
                            text = lv_returnmsg ) )
            TO reported-ticker.
    endloop.

*    "Seçilen satırların verilerini almak için READ ENTITIES kullan
*    READ ENTITIES OF zi_tickerlist
*      IN LOCAL MODE
*      ENTITY Ticker
*      ALL FIELDS
*      WITH CORRESPONDING #( lt_keys )
*      RESULT DATA(lt_tickers)
*      FAILED DATA(lt_failed)
*    REPORTED DATA(lt_reported).
*
*    LOOP AT lt_tickers INTO DATA(ls_ticker).
*      ls_log = corresponding #( ls_ticker  MAPPING kriptoticker    = tickerId
*                                                   kriptoname      = tickerName
*                                                   krcur           = tickerCurr
*                                                   krval           = tickerValue ).
*      ls_log-erdat = sy-datum.
*      APPEND ls_log to gt_log.
*      clear: ls_log.
*    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lsc_zi_tickerlist_ea DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zi_tickerlist_ea IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
    IF lhc_ticker_ea=>gt_log IS NOT INITIAL.
      MODIFY zlcl_t_kripto FROM TABLE @lhc_ticker_ea=>gt_log.
    ENDIF.

  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
