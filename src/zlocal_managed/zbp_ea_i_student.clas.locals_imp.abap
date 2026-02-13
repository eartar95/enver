CLASS lhc_ZEA_I_STUDENT DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR student RESULT result.


    METHODS kabul FOR MODIFY
      IMPORTING keys FOR ACTION student~kabul RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR student RESULT result.
    METHODS validateage FOR VALIDATE ON SAVE
      IMPORTING keys FOR student~validateage.
*    METHODS updatecourseduration FOR DETERMINE ON SAVE
*      IMPORTING keys FOR student~updatecourseduration.
    METHODS updatecourseduration1 FOR DETERMINE ON MODIFY
      IMPORTING keys FOR student~updateCourseDuration1.

    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE student.
*    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
*      IMPORTING REQUEST requested_authorizations FOR student RESULT result.

    METHODS is_update_allowed
      RETURNING VALUE(update_allowed) TYPE abap_bool.
ENDCLASS.

CLASS lhc_ZEA_I_STUDENT IMPLEMENTATION.

  METHOD get_instance_authorizations.

    DATA : update_requested TYPE abap_bool,
           update_grtanted  TYPE abap_bool.

    READ ENTITIES OF zea_i_student IN LOCAL MODE
    ENTITY Student
    FIELDS ( Status ) WITH CORRESPONDING #( keys )
    RESULT DATA(studentadmitted)
    FAILED failed.




    CHECK studentadmitted IS NOT INITIAL.

    update_requested = COND #( WHEN requested_authorizations-%update = if_abap_behv=>mk-on OR
                                    requested_authorizations-%action-Edit = if_abap_behv=>mk-on  THEN
                                    abap_true ELSE abap_false ).

    LOOP AT studentadmitted ASSIGNING FIELD-SYMBOL(<lfs_studentAdmitted>).

      IF <lfs_studentadmitted>-Status = abap_false.
        IF update_requested = abap_true.
          update_grtanted = is_update_allowed(  ).
          IF update_grtanted = abap_false.
            APPEND VALUE #( %tky = <lfs_studentadmitted>-%tky ) TO failed-student.
            APPEND VALUE #( %tky = keys[ 1 ]-%tky
                            %msg = new_message_with_text(
                                   severity = if_abap_behv_message=>severity-error
                                   text = 'Update yetkisi yok !'
                             )
             ) TO reported-student.
          ENDIF.
        ENDIF.
      ENDIF.

    ENDLOOP.


  ENDMETHOD.



  METHOD kabul.

    ""Status hayır olan seçenekleri evet yapıyoruz.Ekstra kontrol olarak status Evet ise buton disabled oluyor.
    MODIFY ENTITIES OF zea_i_student IN LOCAL MODE
    ENTITY Student
    UPDATE
    FIELDS ( Status )
    WITH VALUE #( FOR key IN keys ( %tky = key-%tky Status = abap_true ) )

    FAILED failed
    REPORTED reported.

    "Get the response updated record

    READ ENTITIES OF zea_i_student IN LOCAL MODE
    ENTITY Student
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(studentdata).

    result = VALUE #( FOR studentrec IN studentdata
      ( %tky  = studentrec-%tky %param = studentrec )
       ).

    "--- 📌 MESAJ EKLEME (RAP)
    APPEND VALUE #(
        %tky = keys[ 1 ]-%tky   "hangi kayda ait olduğunu belirt
        %msg = new_message(
                  id       = 'ZEA_MC_STUDENT'         "T100 mesaj sınıfın
                  number   = '001'              "mesaj numarası
                  severity = if_abap_behv_message=>severity-information
*                v1       = 'Status güncellendi'  "opsiyonel değişken
              )
    ) TO reported-student.

  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF zea_i_student IN LOCAL MODE
  ENTITY Student
  FIELDS ( Status ) WITH CORRESPONDING #( keys )
  RESULT DATA(studentadmitted)
  FAILED failed.


    result = VALUE #(
    FOR stud IN studentadmitted
    LET statusval = COND #( WHEN stud-Status = abap_true
                            THEN if_abap_behv=>fc-o-disabled
                            ELSE if_abap_behv=>fc-o-enabled )

                            IN ( %tky = stud-%tky
                                %action-Kabul = statusval
                            )
     ).
  ENDMETHOD.

  METHOD validateAge.

    READ ENTITIES OF zea_i_student IN LOCAL MODE
  ENTITY Student
  FIELDS ( Age ) WITH CORRESPONDING #( keys )
  RESULT DATA(studentsAge).

    LOOP AT studentsage INTO DATA(studentAge).

      IF studentage-Age < 21.
        APPEND VALUE #( %tky = studentage-%tky ) TO failed-student.

        APPEND VALUE #( %tky = keys[ 1 ]-%tky
                        %msg = new_message_with_text(
                        severity = if_abap_behv_message=>severity-error
                        text = 'Yaş 21den küçük olamaz!'
                         ) ) TO reported-student.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

*  METHOD updateCourseDuration.
*
*    READ ENTITIES OF zea_i_student IN LOCAL MODE
*    ENTITY Student
*    FIELDS ( Course ) WITH CORRESPONDING #( keys )
*    RESULT DATA(studentsCourse).
*
*    LOOP AT studentscourse INTO DATA(studentcourse).
*      IF studentcourse-Course = 'Computers'.
*
*        MODIFY ENTITIES OF zea_i_student IN LOCAL MODE
*        ENTITY Student
*        UPDATE
*        FIELDS ( Courseduration ) WITH VALUE #( ( %tky = studentcourse-%tky Courseduration = 5 ) ).
*
*      ELSEIF studentcourse-Course = 'Electronics'.
*
*        MODIFY ENTITIES OF zea_i_student IN LOCAL MODE
*        ENTITY Student
*        UPDATE
*        FIELDS ( Courseduration ) WITH VALUE #( ( %tky = studentcourse-%tky Courseduration = 3 ) ).
*
*      ENDIF.
*
*    ENDLOOP.
*
*  ENDMETHOD.

  METHOD updateCourseDuration1.

    READ ENTITIES OF zea_i_student IN LOCAL MODE
    ENTITY Student
    FIELDS ( Course ) WITH CORRESPONDING #( keys )
    RESULT DATA(studentsCourse).

    LOOP AT studentscourse INTO DATA(studentcourse).
      IF studentcourse-Course = 'Computers'.

        MODIFY ENTITIES OF zea_i_student IN LOCAL MODE
        ENTITY Student
        UPDATE
        FIELDS ( Courseduration ) WITH VALUE #( ( %tky = studentcourse-%tky Courseduration = 5 ) ).

      ELSEIF studentcourse-Course = 'Electronics'.

        MODIFY ENTITIES OF zea_i_student IN LOCAL MODE
        ENTITY Student
        UPDATE
        FIELDS ( Courseduration ) WITH VALUE #( ( %tky = studentcourse-%tky Courseduration = 3 ) ).

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD precheck_update.


    LOOP AT entities  ASSIGNING FIELD-SYMBOL(<lfs_entity>).
*    01 = value is updated / changed , 00 = value is not changed

      CHECK <lfs_entity>-%control-Course EQ '01' OR
            <lfs_entity>-%control-Courseduration EQ '01'.

      READ ENTITIES OF zea_i_student IN LOCAL MODE
  ENTITY Student
  FIELDS ( Course Courseduration ) WITH VALUE #( ( %key = <lfs_entity>-%key ) )
  RESULT DATA(lt_studentsCourse).

      IF sy-subrc EQ 0.
        READ TABLE lt_studentscourse ASSIGNING FIELD-SYMBOL(<lfs_db_course>) INDEX 1.
        IF sy-subrc EQ 0.
          <lfs_db_course>-Course = COND #( WHEN <lfs_entity>-%control-Course EQ '01' THEN
                                                 <lfs_entity>-Course ELSE <lfs_db_course>-Course ).

          <lfs_db_course>-Courseduration  = COND #( WHEN <lfs_entity>-%control-Courseduration EQ '01' THEN
                                        <lfs_entity>-Courseduration ELSE <lfs_db_course>-Courseduration ).


          IF <lfs_db_course>-Courseduration < 5.
            IF <lfs_db_course>-Course = 'Computers'.
              APPEND VALUE #( %tky = <lfs_entity>-%tky ) TO failed-student.

              APPEND VALUE #( %tky = <lfs_entity>-%tky
                              %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                            text = 'Invalid Course Duration' ) ) TO reported-student.


            ENDIF.
          ENDIF.
        ENDIF.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

*  METHOD get_global_authorizations.
*
*    IF requested_authorizations-%update = if_abap_behv=>mk-on OR
*       requested_authorizations-%action-Edit = if_abap_behv=>mk-on.
*
*      IF is_update_allowed( ) = abap_true.
*        result-%update = if_abap_behv=>auth-allowed.
*        result-%action-Edit = if_abap_behv=>auth-allowed.
*      ELSE.
*        result-%update = if_abap_behv=>auth-unauthorized.
*        result-%action-Edit = if_abap_behv=>auth-unauthorized.
*      ENDIF.
*    ENDIF.
*
*  ENDMETHOD.

  METHOD is_update_allowed.
    update_allowed = abap_true.
*    update_allowed = abap_false.
  ENDMETHOD.

ENDCLASS.
