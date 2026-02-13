CLASS zea_cl_send_email DEFINITION
PUBLIC
FINAL
CREATE PUBLIC .

PUBLIC SECTION.
CLASS-METHODS: send_email IMPORTING iv_recipient TYPE zea_de_recipientadress it_data TYPE zea_tt_deliverydetails
EXPORTING ev_mail_message TYPE string.
PROTECTED SECTION.
PRIVATE SECTION.
ENDCLASS.



CLASS ZEA_CL_SEND_EMAIL IMPLEMENTATION.


METHOD send_email.

TRY.
"Creating a new, empty XLSX document and obtaining write access for it
DATA(lo_write_access) = xco_cp_xlsx=>document->empty( )->write_access( ).

"An empty XLSX document consists of one worksheet (named Sheet1 which is accessible via
DATA(lo_worksheet) = lo_write_access->get_workbook( )->worksheet->at_position( 1 ).


"Write the Package Delivery Date at cells B2 and C2
DATA(lo_cursor) = lo_worksheet->cursor(
io_column = xco_cp_xlsx=>coordinate->for_alphabetic_value( 'B' )
io_row = xco_cp_xlsx=>coordinate->for_numeric_value( 2 )
).


" Write the current date.
lo_cursor->get_cell( )->value->write_from( 'Package Delivery Date:' ).


DATA(lv_date) = CONV d( xco_cp=>sy->date( )->as( xco_cp_time=>format->abap )->value ).
lo_cursor->move_right( )->get_cell( )->value->write_from( lv_date ).


"Print Row Headers from cell B3
lo_cursor->move_down( )->move_left( )->get_cell( )->value->write_from( 'Package Number' ).
lo_cursor->move_right( )->get_cell( )->value->write_from( 'Recepient Name' ).
lo_cursor->move_right( )->get_cell( )->value->write_from( 'Recepient Address' ).


" A selection pattern that was obtained via XCO_CP_XLSX_SELECTION=>PATTERN_BUILDER. This will write data from cell B5
DATA(lo_selection_pattern) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to(
)->from_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( 'B' )
)->from_row( xco_cp_xlsx=>coordinate->for_numeric_value( 5 )
)->get_pattern( ).




"Write rows of internal table it_data to worksheet
lo_worksheet->select( lo_selection_pattern
)->row_stream(
)->operation->write_from( REF #( it_data )
)->set_value_transformation( xco_cp_xlsx_write_access=>value_transformation->best_effort
)->execute( ).




"Once the worksheet has been filled as desired, the corresponding file content of the document can be obtained as an XSTRING via


DATA(lv_file_content) = lo_write_access->get_file_content( ).


"Create the mail content with the Url to access the application. The Url consists of the filter condition passed as query string parameters


DATA(lv_today) = cl_abap_context_info=>get_system_date( ).
TRY.
DATA(lv_url) = |https://| & |{ cl_abap_context_info=>get_system_url( ) }| & |/ui#Deliveries-maintain?DeliveryAgentEmail=|
& |{ iv_recipient }| & |&DeliveryDate=| & |{ lv_today }|.
CATCH cx_abap_context_info_error.
ENDTRY.


DATA(lv_content) = |<h1 style="font-family:Helvetica;color:#000000;">Package Delivery Details are Available</h1>| &
|<p style="font-family:Helvetica;font-size:14px;font-style:normal;font-weight:normal;color:#000000;">Dear Delivery Agent,<br/><br/>| &
|Please check the attached file for the list of packages to be delivered today. | &
|Alternatively, you can view your packages to be delivered in the app <a href="| & |{ lv_url }| &
|">here.</a><br/><br/>| &
|Thanks and Best Regards,<br/>Package Delivery Services</p>|.


DATA(lo_mail) = cl_bcs_mail_message=>create_instance( ).


TRY.
DATA(lv_email_domain) = segment( val = cl_abap_context_info=>get_system_url( ) index = 1 sep = '.' ).
CATCH cx_abap_context_info_error.
ENDTRY.


*DATA(lv_sender_email) = |noreply@| & |{ lv_email_domain }| & |.mail.s4hana.ondemand.com|.
DATA(lv_sender_email) = | enver.artar@btc-ag.com.tr |.


lo_mail->set_sender( CONV #( lv_sender_email ) ).
lo_mail->add_recipient( CONV #( iv_recipient ) ).
lo_mail->set_subject( 'Package deliveries for the day' ).


lo_mail->set_main( cl_bcs_mail_textpart=>create_instance(
iv_content = lv_content
iv_content_type = 'text/html'
) ).


lo_mail->add_attachment( cl_bcs_mail_binarypart=>create_instance(
iv_content = lv_file_content
iv_content_type = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
iv_filename = 'Deliveries.xlsx'
) ).


lo_mail->send( IMPORTING et_status = DATA(lt_status) ).


CATCH cx_bcs_mail INTO DATA(lx_mail).
"Pass the Exception text to the output parameter ev_mail_message so that the test class can print it to the console
ev_mail_message = lx_mail->get_text( ) .


ENDTRY.
ENDMETHOD.
ENDCLASS.
