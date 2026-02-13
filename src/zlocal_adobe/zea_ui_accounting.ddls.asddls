@EndUserText.label: 'UI Form'
@ObjectModel.query.implementedBy: 'ABAP:ZEA_CL_ACCOUNTING'
define root custom entity ZEA_UI_ACCOUNTING
{
      @UI        : { lineItem: [ { position: 10, label: 'Şirket Kodu', importance: #HIGH } ] }
      @UI.identification: [ { position: 10, label: 'Şirket Kodu' } ]
      @UI.fieldGroup: [ { qualifier: 'KeyGroup', position: 10 } ]
  key bukrs      : bukrs;


      @UI        : { lineItem: [ { position: 20, label: 'Belge No', importance: #HIGH } ] }
      @UI.identification: [ { position: 20, label: 'Belge No' } ]
      @UI.fieldGroup: [ { qualifier: 'KeyGroup', position: 10 } ]
  key belnr      : belnr_d;


      @UI        : { lineItem: [ { position: 30, label: 'Belge Yılı', importance: #HIGH } ] }
      @UI.identification: [ { position: 30, label: 'Belge Yılı' } ]
      @UI.fieldGroup: [ { qualifier: 'KeyGroup', position: 10 } ]
  key gjahr      : gjahr;

      @UI        :
                   { fieldGroup:     [ { position: 40, qualifier: 'Download' , label: 'HTML dosyası'} ]}
      @Semantics.largeObject: { mimeType: 'mimetype', fileName: 'filename', contentDispositionPreference: #INLINE }
      attachment : zbtctr_eint_de_507;

      @Semantics.mimeType: true
      @UI.hidden : true
      mimetype   : zbtctr_eint_de_508;

      @UI.hidden : true
      filename   : zbtctr_eint_de_509;

}
