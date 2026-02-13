@EndUserText.label: 'File Stream'
define root abstract entity ZEA_D_FILE_STREAM

{
    
  @Semantics.largeObject.mimeType: 'MimeType'
  @Semantics.largeObject.fileName: 'FileName'
  @Semantics.largeObject.contentDispositionPreference: #INLINE
  @EndUserText.label: 'Select XLSX file'
  StreamProperty : abap.rawstring(0);

  @UI.hidden: true
  MimeType : abap.char(128);

  @UI.hidden: true
  FileName : abap.char(128);

    
}
