CLASS zea_cl_accounting DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS get_pdf_from_ads
      RETURNING VALUE(ev_pdf) TYPE xstring.

ENDCLASS.



CLASS ZEA_CL_ACCOUNTING IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    DATA business_data  TYPE TABLE OF ZEA_UI_ACCOUNTING.
    DATA ls_data LIKE LINE OF business_data.
    DATA business_data2 TYPE TABLE OF ZEA_UI_ACCOUNTING.
    DATA(top)     = io_request->get_paging( )->get_page_size( ).
    DATA(skip)    = io_request->get_paging( )->get_offset( ).
    DATA(requested_fields)  = io_request->get_requested_elements( ).
    DATA(sort_order)    = io_request->get_sort_elements( ).
    DATA(lt_parameters) = io_request->get_parameters( ).
    DATA(lt_ranges) = io_request->get_filter( )->get_as_ranges( ).
    DATA(lv_sql_filter) = io_request->get_filter( )->get_as_sql_string( ).
    DATA lv_total_lines TYPE int8.

    DATA lv_top TYPE i.
    DATA(lf_pdf_req) = abap_false.
    DATA(lf_xml_req) = abap_false.

    IF io_request->is_data_requested( ).

      ls_data-belnr = '357901234'.
      ls_data-bukrs = '2000'.
      ls_data-gjahr = '2025'.
      ls_data-attachment = get_pdf_from_ads( ).
      ls_data-mimetype = 'APPLICATION/HTML'. "'PDF'.
      ls_data-filename = 'AdobeformDosya.pdf'.
      APPEND ls_data TO business_data.
      io_response->set_data( business_data ).
    ENDIF.

    lv_total_lines = lines( business_data ).

    IF io_request->is_total_numb_of_rec_requested( ).
      io_response->set_total_number_of_records( lv_total_lines ).
    ENDIF.

  ENDMETHOD.


  METHOD get_pdf_from_ads.

    DATA: lv_xdp_layo    TYPE xstring,
          lv_form_name   TYPE fpname,
          lv_locale      TYPE string,
          lv_xml_data    TYPE xstring,
          lv_xstring_pdf TYPE xstring,
          lv_xml         TYPE string.

    DATA: lt_form_hdr TYPE TABLE OF zea_i_hdr_accounting,
          ls_form_hdr LIKE LINE OF lt_form_hdr.

    TYPES: ty_item TYPE zea_i_item_accounting.
    TYPES: tt_item TYPE TABLE OF ty_item.

    DATA: lt_items    TYPE TABLE OF ty_item.

    DATA: BEGIN OF ls_form_deep,
            zea_i_hdr_accounting TYPE zea_i_hdr_accounting,
            _items               TYPE TABLE OF zea_i_item_accounting,
          END OF ls_form_deep.

    DATA: BEGIN OF ls_form,
            form LIKE ls_form_deep,
          END OF ls_form.

    DATA: ls_form_item  TYPE ty_item.
    DATA: ls_hdr TYPE zea_i_hdr_accounting.
*
*    ls_hdr-CompanyCode         = '1000'.
*    ls_hdr-PurchaseOrder       = '1234567890'.

    ls_hdr-CompanyCode = '2000'.
    ls_hdr-FiscalYear = '2025'.
    ls_hdr-AccountingDocument = '1357901234'.
    ls_hdr-AccountingDocumentType = 'RV'.
    ls_hdr-DocumentDate = '20251101'.
    ls_hdr-FiscalPeriod = '11'.
    ls_hdr-PostingDate = '20251101'.

*
*    ls_form_item-Material             = 'TAHA'.
*    ls_form_item-PurchaseOrder        = '1234567890'.
*    ls_form_item-Plant                = '0001'.
*    ls_form_item-PurchaseOrderItem    = '10'.

    ls_form_item-CompanyCode = '2000'.
    ls_form_item-FiscalYear = '2025'.
    ls_form_item-AccountingDocument = '1357901234'.
    ls_form_item-LedgerGLLineItem = '01'.
    ls_form_item-DocumentDate = '20251101'.
    ls_form_item-PostingDate = '20251101'.
    ls_form_item-Ledger = '0L'.
    ls_form_item-GLAccount = '1290381456'.
    APPEND ls_form_item TO lt_items.
*
*    ls_form_item-Material            = 'ENVER'.
*    ls_form_item-PurchaseOrder       = '1234567890'.
*    ls_form_item-PurchaseOrderItem   = '20'.
*    ls_form_item-Plant               = '0002'.
        ls_form_item-CompanyCode = '2000'.
    ls_form_item-FiscalYear = '2025'.
    ls_form_item-AccountingDocument = '1357901234'.
    ls_form_item-LedgerGLLineItem = '02'.
    ls_form_item-DocumentDate = '20251101'.
    ls_form_item-PostingDate = '20251101'.
    ls_form_item-Ledger = '0L'.
    ls_form_item-GLAccount = '5555511111'.
    APPEND ls_form_item TO lt_items.

    ls_form-form-zea_i_hdr_accounting = ls_hdr.
    ls_form-form-_items = lt_items.

    CALL TRANSFORMATION zea_tf_accounting
           SOURCE form = ls_form-form
           RESULT XML lv_xml_data.
    DATA(lv_xml_str) = cl_web_http_utility=>decode_utf8( lv_xml_data ).
    lv_form_name = 'ZEA_AF_ACCOUNTING'.

    TRY.
        DATA(lo_form_reader) = cl_fp_form_reader=>create_form_reader(
            iv_formname = lv_form_name
        ).
        lv_xdp_layo = lo_form_reader->get_layout( ).
        lv_locale = sy-langu.

        cl_fp_ads_util=>render_pdf(
          EXPORTING
            iv_xml_data     = lv_xml_data
            iv_xdp_layout   = lv_xdp_layo
            iv_locale       = lv_locale
          IMPORTING
            ev_pdf          = ev_pdf
        ).

      CATCH cx_fp_form_reader cx_fp_ads_util INTO DATA(lx_error).
        " Hata yönetimi
        " ...
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
