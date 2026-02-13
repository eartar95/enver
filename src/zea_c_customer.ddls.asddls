@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Customer Consuption'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}



define root view entity ZEA_C_CUSTOMER as projection on ZEA_I_CUSTOMER

{
 @Consumption.filter.hidden: true
key sourceledger,
  /* Şirket Kodu – ZORUNLU */
  @Consumption.filter: {
    selectionType: #SINGLE,
    multipleSelections: false
  }
  @Consumption.filter.mandatory: true
  @Consumption.valueHelpDefinition: [
    { entity: { name: 'I_CompanyCode', element: 'CompanyCode' } }
  ]
  @UI.selectionField: [{ position: 10 }]
key bukrs,
 @Consumption.filter.hidden: true
key gjahr,
 @Consumption.filter.hidden: true
key belnr,
 @Consumption.filter.hidden: true
key buzei,
 @Consumption.filter.hidden: true
key ledger,
  /* Müşteri No – ZORUNLU */
  @UI.selectionField: [{ position: 20 }]
  @Consumption.filter: {
    selectionType: #SINGLE,
    multipleSelections: false
  }
  @Consumption.filter.mandatory: true
  @Consumption.valueHelpDefinition: [
    { entity: { name: 'I_Customer', element: 'Customer' } }
  ]
customer,
 @Consumption.filter.hidden: true
hesap,
@Semantics.amount.currencyCode: 'waers'
 @Consumption.filter.hidden: true
dmbtr,
 @Consumption.filter.hidden: true
waers,
 @Consumption.filter.hidden: true
color,
@Semantics.amount.currencyCode: 'waers'
@ObjectModel.virtualElementCalculatedBy: 'ABAP:ZEA_CL_BAKIYE'
@Consumption.filter.hidden: true
   
virtual bakiye: dmbtr,
  /* ÖDK – Çoklu Seçim */
  @UI.selectionField: [{ position: 30 }]
  @Consumption.filter: {
    selectionType: #RANGE,
    multipleSelections: true
  }
  
  @Consumption.valueHelpDefinition: [
  {
    entity: {
      name: 'I_SpecialGLCode',
      element: 'SpecialGLCode'
    }
  }
]
umskz,
  /* Kayıt Tarihi – Range */
  @UI.selectionField: [{ position: 40 }]
  @Consumption.filter: {
    selectionType: #RANGE,
    multipleSelections: true
  }
budat,



  /* Checkbox – Devir Bakiyeyi Dahil Et */
  @UI.selectionField: [{ position: 50 }]
  @Consumption.filter: {
    selectionType: #SINGLE,
    multipleSelections: false,
    defaultValue: ' '
  }

  @EndUserText.label: 'Devir Bakiye Dahil Et'
  devir_bakiye_dahil
 
  
}
