CLASS zlc_ce_ticker_ea DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES if_rap_query_provider.
      CONSTANTS: gc_curr TYPE zlcl_de_tickercurr value 'USD',
               gc_url   TYPE string value 'https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest?symbol=',
               gc_tickers_all TYPE string value 'BTC,ETH,SOL,XRP,HYPE,EIGEN,ARB,ENA'.
  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES: tt_ticker TYPE TABLE OF zi_tickerlist_ea.
ENDCLASS.



CLASS ZLC_CE_TICKER_EA IMPLEMENTATION.


    METHOD if_rap_query_provider~select.
    DATA: lt_entity TYPE TABLE OF zi_tickerlist_ea,
          ls_entity LIKE LINE OF lt_entity.

    DATA lv_top         TYPE i.
    DATA(filter)  = io_request->get_filter( ).
    DATA(top)     = io_request->get_paging( )->get_page_size( ).
    DATA(skip)    = io_request->get_paging( )->get_offset( ).
    DATA(requested_fields)  = io_request->get_requested_elements( ).
    DATA(sort_order)    = io_request->get_sort_elements( ).
    DATA(lt_parameters) = io_request->get_parameters( ).
    TRY.
        DATA(lt_ranges) = io_request->get_filter( )->get_as_ranges( ).
    CATCH cx_rap_query_filter_no_range INTO DATA(lx).
      io_response->set_data( lt_entity ). " boş dön ama yine de set et
      RETURN.
    ENDTRY.
    DATA(lv_sql_filter) = io_request->get_filter( )->get_as_sql_string( ).

*    DATA lv_url   TYPE string VALUE
*      'https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest?symbol=BTC,ETH,SOL,XRP,HYPE,EIGEN,ARB,ENA'.
    DATA: lv_url        TYPE string.
    DATA: lv_api_key    TYPE string VALUE '3186e5e6-9aad-4166-95fa-c88f04ad2d5e'.

    IF io_request->is_data_requested( ).

    "ticker çekme kodu. yukarıdaki yapıya uyarlanacak...

    if lt_ranges IS INITIAL.
        lv_url = gc_url && gc_tickers_all.
    else.
        data: lf_v.
        lv_url = gc_url.
        loop at lt_ranges into data(ls_range) where name eq 'TICKERID'.
            LOOP AT ls_range-range into data(ls_rt) where sign eq 'I' and option EQ 'EQ'.
                if lf_v eq space.
                    lf_v = 'X'.
                    lv_url = lv_url && ls_rt-low.
                else.
                    lv_url = lv_url && ',' && ls_rt-low.
                endif.
            endloop.
        endloop.
    endif.



    " HTTP client
    DATA(lo_dest)       = cl_http_destination_provider=>create_by_url( i_url = lv_url ).
    DATA(lo_http)       = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).
    "DATA(lo_http)       = cl_web_http_client_manager=>create_by_url( i_url = lv_url ).
    DATA(lo_request)    = lo_http->get_http_request( ).
    "DATA(lo_response)   = lo_http->get_http_response( ).



    lo_request->set_header_field( i_name = 'Content-Type' i_value = 'application/json' ).
    lo_request->set_header_field( i_name = 'X-CMC_PRO_API_KEY' i_value = lv_api_key ).

    TRY.
        DATA(lo_response) = lo_http->execute( if_web_http_client=>get ).
      CATCH cx_web_http_client_error INTO DATA(lx_err).
*        out->write( |API hatası: { lx_err->get_text( ) }| ).
*        RETURN.
    ENDTRY.

    DATA(lv_json) = lo_response->get_text( ).

    DATA lr_root TYPE REF TO data.
    TRY.
        /ui2/cl_json=>deserialize(
          EXPORTING json = lv_json
          CHANGING  data = lr_root ).
      CATCH cx_root INTO DATA(lx2).
        RAISE EXCEPTION NEW cx_sy_conversion_no_number( ).
    ENDTRY.

    FIELD-SYMBOLS: <root>        TYPE any,
                   <data>        TYPE any,
                   <data_str>    TYPE any,
                   <coin>        TYPE any,
                   <coin_str>    TYPE any,
                   <quote>       TYPE any,
                   <quote_str>   TYPE any,
                   <cur_node>    TYPE any,
                   <cur_node_str> TYPE any,
                   <usd>         TYPE any.

    ASSIGN lr_root->* TO <root>.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    " root altında 'status' ve 'data' var.
    ASSIGN COMPONENT 'DATA' OF STRUCTURE <root> TO <data>.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    " Δ: DATA referans gelebilir → deref et
    DATA(lo_td_data) = cl_abap_typedescr=>describe_by_data( <data> ).
    IF lo_td_data IS INSTANCE OF cl_abap_refdescr.
      DATA lr_data TYPE ref to data.
      lr_data ?= <data>.
      ASSIGN lr_data->* TO <data_str>.
    ELSE.
      ASSIGN <data> TO <data_str>.
    ENDIF.
    IF <data_str> IS NOT ASSIGNED.
      RETURN.
    ENDIF.

    " 2) RTTS ile DATA altındaki tüm coin key'lerini topla (artık <data_str> üstünden)
    DATA(lo_data_desc) = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_data( <data_str> ) ).
    DATA(lt_comps)     = lo_data_desc->get_components( ).

    DATA lt_kripto TYPE STANDARD TABLE OF zlcl_t_kripto.
    DATA ls_kripto TYPE zlcl_t_kripto.

    LOOP AT lt_comps INTO DATA(ls_comp).
      " ls_comp-name = 'BTC' / 'ETH' / ...
      ASSIGN COMPONENT ls_comp-name OF STRUCTURE <data_str> TO <coin>.
      IF sy-subrc <> 0 OR <coin> IS INITIAL.
        CONTINUE.
      ENDIF.

      " Δ: COIN de referans olabilir → deref et
      DATA(lo_td_coin) = cl_abap_typedescr=>describe_by_data( <coin> ).
      IF lo_td_coin IS INSTANCE OF cl_abap_refdescr.
         DATA lr_coin TYPE REF TO data.
        lr_coin ?= <coin>.
        ASSIGN lr_coin->* TO <coin_str>.
      ELSE.
        ASSIGN <coin> TO <coin_str>.
      ENDIF.
      IF <coin_str> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.

      " name
      DATA lv_name TYPE zlcl_de_tickername.
      lv_name = ls_comp-name.
      FIELD-SYMBOLS <name> TYPE any.
      FIELD-SYMBOLS <name_val> TYPE any.
      ASSIGN COMPONENT 'NAME' OF STRUCTURE <coin_str> TO <name>.
      IF sy-subrc = 0 AND <name> IS ASSIGNED.
        "lv_name = CONV zlcl_de_tickername( <name> ).
          DATA(lo_td_name) = cl_abap_typedescr=>describe_by_data( <name> ).
          IF lo_td_name IS INSTANCE OF cl_abap_refdescr.
            DATA lr_name TYPE REF TO data.
            lr_name ?= <name>.
            ASSIGN lr_name->* TO <name_val>.
            IF sy-subrc = 0 AND <name_val> IS ASSIGNED.
              lv_name = CONV zlcl_de_tickername( CONV string( <name_val> ) ).
            ENDIF.
          ELSE.
            lv_name = CONV zlcl_de_tickername( CONV string( <name> ) ).
          ENDIF.
      ENDIF.

      " quote -> USD -> price
      ASSIGN COMPONENT 'QUOTE' OF STRUCTURE <coin_str> TO <quote>.
      IF sy-subrc <> 0 OR <quote> IS INITIAL.
        CONTINUE.
      ENDIF.

      " Δ: QUOTE da referans olabilir → deref et
      DATA(lo_td_quote) = cl_abap_typedescr=>describe_by_data( <quote> ).
      IF lo_td_quote IS INSTANCE OF cl_abap_refdescr.
         DATA lr_quote TYPE REF TO data.
        lr_quote ?= <quote>.
        ASSIGN lr_quote->* TO <quote_str>.
      ELSE.
        ASSIGN <quote> TO <quote_str>.
      ENDIF.
      IF <quote_str> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.

      " Önce istedigin para birimi (USD); yoksa ilkini dene
       ASSIGN COMPONENT gc_curr OF STRUCTURE <quote_str> TO <cur_node>.
      IF sy-subrc <> 0 OR <cur_node> IS INITIAL.
        " USD yoksa ilk component'i dene
        DATA(lo_q_desc)  = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_data( <quote_str> ) ).
        DATA(lt_q_comps) = lo_q_desc->get_components( ).
        READ TABLE lt_q_comps INDEX 1 INTO DATA(ls_qc).
        IF sy-subrc = 0.
          ASSIGN COMPONENT ls_qc-name OF STRUCTURE <quote_str> TO <cur_node>.
        ENDIF.
      ENDIF.
      IF sy-subrc <> 0 OR <cur_node> IS INITIAL.
        CONTINUE.
      ENDIF.

      " Δ: currency düğümü de ref olabilir → deref et
      DATA(lo_td_cur) = cl_abap_typedescr=>describe_by_data( <cur_node> ).
      IF lo_td_cur IS INSTANCE OF cl_abap_refdescr.
        DATA lr_cur TYPE REF TO data.
        lr_cur ?= <cur_node>.
        ASSIGN lr_cur->* TO <cur_node_str>.
      ELSE.
        ASSIGN <cur_node> TO <cur_node_str>.
      ENDIF.
      IF <cur_node_str> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.

      FIELD-SYMBOLS <price> TYPE any.
      FIELD-SYMBOLS <price_val> TYPE any.
      DATA lv_price TYPE zlcl_de_tickervalue.
      ASSIGN COMPONENT 'PRICE' OF STRUCTURE <cur_node_str> TO <price>.
      IF sy-subrc = 0 AND <price> IS ASSIGNED.
          DATA(lo_td_price) = cl_abap_typedescr=>describe_by_data( <price> ).
          IF lo_td_price IS INSTANCE OF cl_abap_refdescr.
            DATA lr_price TYPE REF TO data.
            lr_price ?= <price>.
            ASSIGN lr_price->* TO <price_val>.
            IF sy-subrc EQ 0 AND <price_val> IS ASSIGNED.
              lv_price = CONV #( CONV decfloat34( <price_val> ) ).
            ENDIF.
          ELSE.
            lv_price = CONV #( CONV decfloat34( <price> ) ).
          ENDIF.

      ENDIF.

      " 3) ZLCL_T_KRIPTO satırını doldur
      CLEAR ls_kripto.
      "ls_kripto"-mandt        = sy-mandt.              " client-dependent ise
      ls_kripto-kriptoticker = ls_comp-name.
      ls_kripto-erdat        = sy-datum.
      ls_kripto-kriptoname   = lv_name.
      ls_kripto-krval        = lv_price.
      ls_kripto-krcur        = gc_curr.

      APPEND ls_kripto TO lt_kripto.

      ls_entity = CORRESPONDING #(  ls_kripto MAPPING tickerId = kriptoticker
                                                      tickerName = kriptoname
                                                      tickerCurr = krcur
                                                      tickerValue  = krval ).

      APPEND ls_entity TO lt_entity.
      CLEAR: ls_entity.

    ENDLOOP.

*    IF lt_kripto IS NOT INITIAL.
*      MODIFY zlcl_t_kripto FROM TABLE @lt_kripto.
*      COMMIT WORK.
*    ENDIF.

    io_response->set_data( lt_entity ).

    IF io_request->is_total_numb_of_rec_requested( ).
      io_response->set_total_number_of_records( lines( lt_entity ) ).
    ENDIF.

    ENDIF.
    ENDMETHOD.
ENDCLASS.
