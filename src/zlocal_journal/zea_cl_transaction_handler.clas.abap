CLASS zea_cl_transaction_handler DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-DATA: go_instance TYPE REF TO zea_cl_transaction_handler.

    CLASS-METHODS: get_instance RETURNING VALUE(result) TYPE REF TO zea_cl_transaction_handler.

    TYPES: BEGIN OF ty_temp_key,
             cid TYPE abp_behv_cid,
             pid TYPE abp_behv_pid,
           END OF ty_temp_key,
           tt_temp_key TYPE STANDARD TABLE OF ty_temp_key WITH DEFAULT KEY,
           BEGIN OF ty_final_key,
             cid   TYPE abp_behv_cid,
             bukrs TYPE bukrs,
             belnr TYPE belnr_d,
             gjahr TYPE gjahr,
           END OF ty_final_key,
           tt_final_key TYPE STANDARD TABLE OF ty_final_key WITH DEFAULT KEY,
           tt_header    TYPE STANDARD TABLE OF zea_journal_h WITH DEFAULT KEY.

    DATA: temp_key     TYPE tt_temp_key.

    METHODS: set_temp_key IMPORTING it_temp_key TYPE tt_temp_key,
      convert_temp_to_final RETURNING VALUE(result) TYPE tt_final_key,
      additional_save IMPORTING it_create TYPE tt_header
                                it_delete TYPE tt_header,
      clean_up.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zea_cl_transaction_handler IMPLEMENTATION.

  METHOD get_instance.
    IF go_instance IS NOT BOUND.
      go_instance = NEW #( ).
    ENDIF.
    result = go_instance.
  ENDMETHOD.

  METHOD additional_save.

    DATA: lt_create TYPE TABLE OF zea_journal_h.

    DATA(lt_je_key) = convert_temp_to_final(  ).

    LOOP AT it_create INTO DATA(ls_create).
      READ TABLE lt_je_key INTO DATA(ls_je_key) WITH KEY cid = ls_create-uuid.
      IF sy-subrc = 0.
        ls_create-belnr = ls_je_key-belnr.
        APPEND ls_create TO lt_create.
      ENDIF.
    ENDLOOP.

    IF lt_create IS NOT INITIAL.
      INSERT zea_journal_h FROM TABLE @lt_create.
    ENDIF.

    IF it_delete IS NOT INITIAL.
      DELETE zea_journal_h FROM TABLE @it_delete.
    ENDIF.

  ENDMETHOD.

  METHOD clean_up.
    CLEAR temp_key.
  ENDMETHOD.

  METHOD convert_temp_to_final.
    DATA: ls_final_key TYPE ty_final_key.
    IF temp_key IS NOT INITIAL.
      LOOP AT temp_key INTO DATA(ls_temp_key).
        CONVERT KEY OF i_journalentrytp
          FROM ls_temp_key-pid
          TO FINAL(lv_root_key).

        ls_final_key-cid = ls_temp_key-cid.
        ls_final_key-bukrs = lv_root_key-companycode.
        ls_final_key-belnr = lv_root_key-accountingdocument.
        ls_final_key-gjahr = lv_root_key-fiscalyear.

        APPEND ls_final_key TO result.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD set_temp_key.
    temp_key = it_temp_key.
  ENDMETHOD.
ENDCLASS.
