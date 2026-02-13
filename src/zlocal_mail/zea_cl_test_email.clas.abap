CLASS zea_cl_test_email DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZEA_CL_TEST_EMAIL IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    zea_cl_send_email=>send_email( EXPORTING it_data = VALUE #( ( package_number = '1001' recipient_name = 'Enver Artar' recipient_address = `EARTAR's Address ` ) )
  iv_recipient = 'enver.artar@btc-ag.com.tr' IMPORTING ev_mail_message = DATA(iv_message) ).
    out->write( iv_message ).
  ENDMETHOD.
ENDCLASS.
