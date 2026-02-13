CLASS zea_cl_calculate DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_sadl_exit_calc_element_read.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZEA_CL_CALCULATE IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.
    DATA : lt_studentData TYPE STANDARD TABLE OF zea_c_student WITH DEFAULT KEY.

    lt_studentdata = CORRESPONDING #( it_original_data ).

    LOOP AT lt_studentdata ASSIGNING FIELD-SYMBOL(<lfs_studentdata>).
      IF <lfs_studentdata>-Course = 'Computers'.
        <lfs_studentdata>-TotalDuration = <lfs_studentdata>-Courseduration + 100.
      ELSE.
        <lfs_studentdata>-TotalDuration = <lfs_studentdata>-Courseduration + 200.

      ENDIF.

      ct_calculated_data = CORRESPONDING  #( lt_studentdata ).

    ENDLOOP..
  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.

  ENDMETHOD.
ENDCLASS.
