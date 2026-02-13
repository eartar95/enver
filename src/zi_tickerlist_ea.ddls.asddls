@EndUserText.label: 'Ticker Lists'
@ObjectModel.query.implementedBy: 'ABAP:ZLC_CE_TICKER_EA'
@Metadata.allowExtensions: true
@UI:{ headerInfo: {
    typeName: 'Ticker',
    typeNamePlural: 'Ticker',
    title: {
        type: #STANDARD,
        value: 'tickerId'
    },
    description: {
        type: #STANDARD,
        value: 'tickerName'
    }
} 
}
    
define root custom entity ZI_TICKERLIST_EA

// with parameters parameter_name : parameter_type
{
  
@UI.facet: [
  {
    label: 'Ticker List',
    id: 'GeneralInfo',
    type: #COLLECTION,
    position: 10
  },
  { type: #FIELDGROUP_REFERENCE, targetQualifier: 'KeyGroup', label: 'Primary Keys', position: 10, parentId: 'GeneralInfo' },
  { type: #FIELDGROUP_REFERENCE, targetQualifier: 'ValueGroup', label: 'Ticker Values', position: 20, parentId: 'GeneralInfo' }
]

@UI: { lineItem: [ { position: 10, label: 'Ticker ID', importance: #HIGH } ] }
@UI.identification: [ { position: 10, label: 'Ticker ID' } ]
@UI.fieldGroup: [ { qualifier: 'KeyGroup', position: 10 } ]
key tickerId : zlcl_de_ticker;

@UI: { lineItem: [ { position: 20, label: 'Name', importance: #HIGH } ] }
@UI.identification: [ { position: 20, label: 'Name' } ]
@UI.fieldGroup: [ { qualifier: 'ValueGroup', position: 20 } ]
tickerName : zlcl_de_tickername;

@UI.lineItem: [ { position: 30, label: 'Value', importance: #HIGH } ]
@UI.identification: [ { position: 30, label: 'Value' } ]
@UI.fieldGroup: [ { qualifier: 'ValueGroup', position: 30 } ]
tickerValue : zlcl_de_tickervalue;

@UI.lineItem: [ { position: 40, label: 'Currency', importance: #HIGH } ]
@UI.identification: [ { position: 40, label: 'Currency' } ]
@UI.fieldGroup: [ { qualifier: 'ValueGroup', position: 40 } ]
tickerCurr : zlcl_de_tickercurr;

    @UI: { 
    hidden: true,
    lineItem: [ { position: 10, importance: #HIGH },
                { type: #FOR_ACTION, dataAction: 'saveLog', label: 'Log kaydet' }
              ]
    }
    @UI.identification: [ { position: 10, type: #FOR_ACTION, dataAction: 'saveLog', label: 'Log kaydet' } ]
    btn_saveLog: abap.char(1); 
  
}
