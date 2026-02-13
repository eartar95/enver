CLASS zcl_ea_denemeclass DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
   INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_EA_DENEMECLASS IMPLEMENTATION.


METHOD if_oo_adt_classrun~main.
"deneme123
"Direkt çalıştırılıyor
out->write( |Deneme çalıştırıldı!| ).
endmethod.
ENDCLASS.
