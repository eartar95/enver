CLASS lhc_ZEA_I_JOURNAL DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zea_i_journal RESULT result.

    METHODS Post FOR DETERMINE ON SAVE
      IMPORTING keys FOR zea_i_journal~Post.


    METHODS UploadXlsx FOR MODIFY
      IMPORTING keys   FOR ACTION zea_i_journal~UploadXlsx
      RESULT    result.

    TYPES: BEGIN OF ty_item_row_raw,
             a TYPE string, "Bschl
             b TYPE string, "Hkont
             c TYPE string, "Wrbtr
             d TYPE string, "Sgtxt
             e TYPE string, "Kostl
             f TYPE string, "Prctr
           END OF ty_item_row_raw.

    TYPES: BEGIN OF ty_itm,
             bschl TYPE bschl,
             hkont TYPE hkont,
             wrbtr TYPE wrbtr,
             sgtxt TYPE sgtxt,
             kostl TYPE kostl,
             prctr TYPE prctr,
           END OF ty_itm.


    CLASS-METHODS parse_amount
      IMPORTING iv_text          TYPE string
      RETURNING VALUE(rv_amount) TYPE wrbtr.




ENDCLASS.

CLASS lhc_ZEA_I_JOURNAL IMPLEMENTATION.
  METHOD parse_amount.

    rv_amount = 0.

    DATA(lv) = condense( iv_text ).
    IF lv IS INITIAL.
      RETURN.
    ENDIF.

    REPLACE ALL OCCURRENCES OF ' ' IN lv WITH ''.

    IF lv CS ',' AND lv CS '.'.
      DATA(lv_last_comma) = find( val = lv sub = ',' occ = -1 ).
      DATA(lv_last_dot)   = find( val = lv sub = '.' occ = -1 ).
      IF lv_last_comma > lv_last_dot.
        REPLACE ALL OCCURRENCES OF '.' IN lv WITH ''.
        REPLACE ALL OCCURRENCES OF ',' IN lv WITH '.'.
      ELSE.
        REPLACE ALL OCCURRENCES OF ',' IN lv WITH ''.
      ENDIF.
    ELSEIF lv CS ','.
      REPLACE ALL OCCURRENCES OF '.' IN lv WITH ''.
      REPLACE ALL OCCURRENCES OF ',' IN lv WITH '.'.
    ELSE.
      REPLACE ALL OCCURRENCES OF ',' IN lv WITH ''.
    ENDIF.

    TRY.
        rv_amount = CONV wrbtr( lv ).
      CATCH cx_sy_conversion_no_number.
        rv_amount = 0.
    ENDTRY.


  ENDMETHOD.

  METHOD UploadXlsx.

    "Action result ($self)
    result = VALUE #( FOR k IN keys ( %tky = k-%tky ) ).


    DATA(lv_xlsx) = VALUE xstring(
      keys[ 1 ]-%param-_streamproperties-StreamProperty OPTIONAL ).

    DATA(lv_filename) = VALUE string(
      keys[ 1 ]-%param-_streamproperties-FileName OPTIONAL ).

    DATA(lv_mimetype) = VALUE string(
      keys[ 1 ]-%param-_streamproperties-MimeType OPTIONAL ).


    "Read 1st worksheet using XCO_CP_XLSX (approach shown in SAP example) [1](https://community.sap.com/t5/technology-blog-posts-by-sap/apis-for-journal-entries-the-collection-updated-july-2025/ba-p/13565258)
    DATA(lo_doc) = xco_cp_xlsx=>document->for_file_content( lv_xlsx )->read_access( ).  "[1](https://community.sap.com/t5/technology-blog-posts-by-sap/apis-for-journal-entries-the-collection-updated-july-2025/ba-p/13565258)
    DATA(lo_ws)  = lo_doc->get_workbook( )->worksheet->at_position( 1 ).               "[1](https://community.sap.com/t5/technology-blog-posts-by-sap/apis-for-journal-entries-the-collection-updated-july-2025/ba-p/13565258)

    "Items range: Row 3.., Columns A..F (your confirmed layout)
    DATA lt_item_raw TYPE STANDARD TABLE OF ty_item_row_raw WITH EMPTY KEY.




    DATA(lo_builder) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to( ).

    lo_builder = lo_builder->from_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( 'A' ) ).
    lo_builder = lo_builder->to_column(   xco_cp_xlsx=>coordinate->for_alphabetic_value( 'F' ) ).
    lo_builder = lo_builder->from_row(    xco_cp_xlsx=>coordinate->for_numeric_value( 2 ) ).

    DATA(lo_itm_pat) = lo_builder->get_pattern( ).



    lo_ws->select( lo_itm_pat )->row_stream( )->operation->write_to( REF #( lt_item_raw ) )->set_value_transformation( xco_cp_xlsx_read_access=>value_transformation->string_value )->execute( ).
    "Convert raw -> typed items, skip empty rows
    DATA lt_items TYPE STANDARD TABLE OF ty_itm WITH EMPTY KEY.

    LOOP AT lt_item_raw INTO DATA(ls_raw).



      DATA(lv_a) = ls_raw-a.  CONDENSE lv_a.
      DATA(lv_b) = ls_raw-b.  CONDENSE lv_b.
      DATA(lv_c) = ls_raw-c.  CONDENSE lv_c.
      DATA(lv_d) = ls_raw-d.  CONDENSE lv_d.
      DATA(lv_e) = ls_raw-e.  CONDENSE lv_e.
      DATA(lv_f) = ls_raw-f.  CONDENSE lv_f.

      IF lv_a IS INITIAL
      AND lv_b IS INITIAL
      AND lv_c IS INITIAL
      AND lv_d IS INITIAL
      AND lv_e IS INITIAL
      AND lv_f IS INITIAL.
        CONTINUE.
      ENDIF.


      DATA(ls_itm) = VALUE ty_itm(
        bschl = CONV bschl( lv_a )
        hkont = CONV hkont( lv_b )
*        wrbtr = parse_amount( lv_c )
        wrbtr  = lv_c
        sgtxt = lv_d
        kostl = COND kostl( WHEN lv_e IS INITIAL THEN '' ELSE lv_e )
        prctr = COND prctr( WHEN lv_f IS INITIAL THEN '' ELSE lv_f )
      ).

      IF ls_itm-bschl IS INITIAL OR ls_itm-hkont IS INITIAL.
        APPEND VALUE #( %tky = keys[ 1 ]-%tky
                        %msg = new_message_with_text(
                                  severity = if_abap_behv_message=>severity-error
                                  text     = 'Excel satırında Bschl/Hkont boş olamaz.' ) )
          TO reported-zea_i_journal.
        RETURN.
      ENDIF.

      APPEND ls_itm TO lt_items.
    ENDLOOP.

    "Excel boşsa: HİÇBİR ŞEYİ SİLME, sessizce çık
    IF lt_items IS INITIAL.

      APPEND VALUE #(
          %tky = keys[ 1 ]-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'Excel içinde geçerli kalem satırı bulunamadı!!!.'
                 )
        ) TO reported-zea_i_journal.
      APPEND VALUE #( %tky = keys[ 1 ]-%tky ) TO failed-zea_i_journal.
      RETURN.

    ENDIF.

    "Duplicate bschl check within Excel
    DATA lt_bschl TYPE HASHED TABLE OF bschl WITH UNIQUE KEY table_line.
    LOOP AT lt_items INTO DATA(ls_d).
      READ TABLE lt_bschl WITH TABLE KEY table_line = ls_d-bschl TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        APPEND VALUE #( %tky = keys[ 1 ]-%tky
                        %msg = new_message_with_text(
                                  severity = if_abap_behv_message=>severity-error
                                  text     = |Excel içinde mükerrer Bschl: { ls_d-bschl }| ) )
          TO reported-zea_i_journal.
        RETURN.
      ENDIF.
      INSERT ls_d-bschl INTO TABLE lt_bschl.
    ENDLOOP.

    "Read existing items (draft/local) and DELETE them (overwrite)
    READ ENTITIES OF zea_i_journal IN LOCAL MODE
      ENTITY zea_i_journal BY \_Item
        ALL FIELDS
        WITH VALUE #( ( %tky = keys[ 1 ]-%tky ) )
      RESULT DATA(lt_existing_items).

    IF lt_existing_items IS NOT INITIAL.
      MODIFY ENTITIES OF zea_i_journal IN LOCAL MODE
        ENTITY zea_i_journal_item
          DELETE FROM VALUE #(
            FOR it IN lt_existing_items ( %tky = it-%tky )
          )
        FAILED   DATA(lt_del_failed)
        REPORTED DATA(lt_del_reported).

      IF lt_del_failed IS NOT INITIAL.
        "Opsiyonel: burada sadece hata mesajı bırakıyoruz
        APPEND VALUE #( %tky = keys[ 1 ]-%tky
                        %msg = new_message_with_text(
                                  severity = if_abap_behv_message=>severity-error
                                  text     = 'Mevcut Items silinirken hata oluştu.' ) )
          TO reported-zea_i_journal.
        RETURN.
      ENDIF.
    ENDIF.

    "Create new items by association _Item


    DATA lt_create TYPE TABLE FOR CREATE zea_i_journal\_item.

    APPEND VALUE #(
      %tky    = keys[ 1 ]-%tky
      %target = VALUE #(
        FOR ls_new IN lt_items INDEX INTO idx (
          %cid  = idx
          %is_draft = if_abap_behv=>mk-on
          Uuid = keys[ 1 ]-Uuid
          Bschl = ls_new-bschl
          Hkont = ls_new-hkont
          Wrbtr = ls_new-wrbtr
          Sgtxt = ls_new-sgtxt
          Kostl = ls_new-kostl
          Prctr = ls_new-prctr
          %control-Uuid = if_abap_behv=>mk-on
          %control-Bschl = if_abap_behv=>mk-on
          %control-Hkont = if_abap_behv=>mk-on
          %control-Wrbtr = if_abap_behv=>mk-on
          %control-Sgtxt = if_abap_behv=>mk-on
          %control-Kostl = if_abap_behv=>mk-on
          %control-Prctr = if_abap_behv=>mk-on
        )

      )

    ) TO lt_create.




    MODIFY ENTITIES OF zea_i_journal
    IN LOCAL MODE
    ENTITY zea_i_journal
    CREATE BY \_Item  FROM lt_create
      FAILED   DATA(lt_cr_failed)
      REPORTED DATA(lt_cr_reported)
      MAPPED DATA(lt_mapped).




    IF lt_cr_failed IS NOT INITIAL.
      APPEND VALUE #(
        %tky = keys[ 1 ]-%tky
        %msg = new_message_with_text(
                 severity = if_abap_behv_message=>severity-error
                 text     = 'Items yükleme başarısız.'
               )
      ) TO reported-zea_i_journal.

      APPEND VALUE #( %tky = keys[ 1 ]-%tky ) TO failed-zea_i_journal.
      RETURN.
    ENDIF.

    " Başarılıysa: $self result dön (result [1] $self için stabil)
    READ ENTITIES OF zea_i_journal IN LOCAL MODE
      ENTITY zea_i_journal ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_hdr).

    result = VALUE #( FOR h IN lt_hdr ( %tky = h-%tky %param = h ) ).










    "İstersen success mesajını da kaldırabiliriz; ben minimal tuttum
*    APPEND VALUE #( %tky = keys[ 1 ]-%tky
*                    %msg = new_message_with_text(
*                              severity = if_abap_behv_message=>severity-success
*                              text     = 'Items XLSX ile güncellendi (overwrite).' ) )
*      TO reported-zea_i_journal.


  ENDMETHOD.


  METHOD Post.

    DATA: lt_entry    TYPE TABLE FOR ACTION IMPORT i_journalentrytp~post,
          ls_entry    LIKE LINE OF lt_entry,
          ls_glitem   LIKE LINE OF ls_entry-%param-_glitems,
          ls_amount   LIKE LINE OF ls_glitem-_currencyamount,
          lt_temp_key TYPE zea_cl_transaction_handler=>tt_temp_key,
          ls_temp_key LIKE LINE OF lt_temp_key.

    DATA: lt_je TYPE TABLE FOR FUNCTION IMPORT i_journalentrytp~Validate.
    APPEND INITIAL LINE TO lt_je ASSIGNING FIELD-SYMBOL(<je>).
    <je>-%param = VALUE #( DocumentDate = '20230201' ).

    READ ENTITIES OF zea_i_journal IN LOCAL MODE
        ENTITY zea_i_journal ALL FIELDS WITH CORRESPONDING #( keys ) RESULT FINAL(header)
        ENTITY zea_i_journal BY \_item ALL FIELDS WITH CORRESPONDING #( keys ) RESULT FINAL(item).

    "start to call I_JournalEntryTP~Post
    LOOP AT header REFERENCE INTO DATA(ls_header).
      CLEAR ls_entry.
      ls_entry-%cid = ls_header->uuid. "use UUID as CID
      ls_entry-%param-companycode = ls_header->bukrs.
      ls_entry-%param-businesstransactiontype = 'RFPO'.
      ls_entry-%param-accountingdocumenttype = 'AB'.
      ls_entry-%param-accountingdocumentheadertext = ls_header->bktxt.
      ls_entry-%param-documentdate = ls_header->bldat.
      ls_entry-%param-postingdate = ls_header->budat.
      ls_entry-%param-createdbyuser = ls_header->CreatedBy.

      LOOP AT item REFERENCE INTO DATA(ls_item) USING KEY entity WHERE uuid = ls_header->uuid.
        CLEAR ls_glitem.
        ls_glitem-glaccountlineitem = ls_item->%data-bschl.
        ls_glitem-glaccount         = ls_item->%data-hkont.
        ls_glitem-costcenter        = ls_item->%data-kostl.
        ls_glitem-profitcenter        = ls_item->%data-prctr.
        ls_glitem-documentitemtext       = ls_item->%data-sgtxt.

        CLEAR ls_amount.
        ls_amount-currencyrole = '00'.
        ls_amount-currency = ls_header->waers.
        ls_amount-journalentryitemamount = ls_item->%data-wrbtr.
        APPEND ls_amount TO ls_glitem-_currencyamount.
        APPEND ls_glitem TO ls_entry-%param-_glitems.
      ENDLOOP.
      APPEND ls_entry TO lt_entry.
    ENDLOOP.

    IF lt_entry IS NOT INITIAL.
      MODIFY ENTITIES OF i_journalentrytp
      ENTITY journalentry
      EXECUTE post FROM lt_entry
        MAPPED FINAL(ls_post_mapped)
        FAILED FINAL(ls_post_failed)
        REPORTED FINAL(ls_post_reported).

      IF ls_post_failed IS NOT INITIAL.
        LOOP AT ls_post_reported-journalentry INTO DATA(ls_report).
          APPEND VALUE #( uuid = ls_report-%cid
                          %create = if_abap_behv=>mk-on
                          %is_draft = if_abap_behv=>mk-on
                          %msg = ls_report-%msg ) TO reported-zea_i_journal.
        ENDLOOP.
      ENDIF.

      LOOP AT ls_post_mapped-journalentry INTO DATA(ls_je_mapped).
        ls_temp_key-cid = ls_je_mapped-%cid.
        ls_temp_key-pid = ls_je_mapped-%pid.
        APPEND ls_temp_key TO lt_temp_key.
      ENDLOOP.

    ENDIF.

    zea_cl_transaction_handler=>get_instance( )->set_temp_key( lt_temp_key ).
  ENDMETHOD.



  METHOD get_instance_authorizations.
  ENDMETHOD.



ENDCLASS.

CLASS lsc_ZEA_I_JOURNAL DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZEA_I_JOURNAL IMPLEMENTATION.

  METHOD save_modified.
    "unmanaged save for table zea_journal_h
    DATA: Lt_create TYPE TABLE OF zea_journal_h,
          lt_delete TYPE TABLE OF zea_journal_h.


    lt_create = CORRESPONDING #( create-zea_i_journal MAPPING FROM ENTITY ).
    lt_delete = CORRESPONDING #( delete-zea_i_journal MAPPING FROM ENTITY ).
    zea_cl_transaction_handler=>get_instance( )->additional_save( it_create = lt_create
                                                                it_delete = lt_delete ).
  ENDMETHOD.

  METHOD cleanup_finalize.
    zea_cl_transaction_handler=>get_instance(  )->clean_up(  ).
  ENDMETHOD.

ENDCLASS.
