
@EndUserText.label: 'Upload XLSX Parameter'
define root abstract entity ZEA_D_UPLOAD_XLSX
{
  @UI.hidden: true
  Dummy : abap_boolean;

  _StreamProperties : association [1] to ZEA_D_FILE_STREAM on 1 = 1;
}
