CLASS zea_cl_bakiye DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_sadl_exit_calc_element_read.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZEA_CL_BAKIYE IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.

    DATA: lt_custData TYPE STANDARD TABLE OF zea_c_customer WITH DEFAULT KEY.

    lt_custData = CORRESPONDING #(  it_original_data ).


    DATA lv_bakiye TYPE dmbtr.

    LOOP AT lt_custData ASSIGNING FIELD-SYMBOL(<row>).

      FIELD-SYMBOLS:
        <dmbtr>              TYPE any,
        <bakiye>             TYPE any,
        <devir_bakiye_dahil> TYPE any.

      ASSIGN COMPONENT 'DMBTR'  OF STRUCTURE <row> TO <dmbtr>.
      ASSIGN COMPONENT 'BAKIYE' OF STRUCTURE <row> TO <bakiye>.


      IF <dmbtr> IS ASSIGNED AND <bakiye> IS ASSIGNED.
        lv_bakiye = lv_bakiye + <dmbtr>.
        <bakiye>  = lv_bakiye.
      ENDIF.

    ENDLOOP.

    ASSIGN COMPONENT 'DEVIR_BAKIYE_DAHIL' OF STRUCTURE <row> TO <devir_bakiye_dahil>.



    ct_calculated_data = CORRESPONDING #( lt_custData ).


  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.

  ENDMETHOD.
ENDCLASS.
