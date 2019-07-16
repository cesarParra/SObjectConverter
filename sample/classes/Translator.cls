public with sharing class Translator extends conv_SObjectConverter {
    private static final Map<String, String> translationMap = new Map<String, String> {
        'Yes' => 'Si'
    };

    Schema.SObjectType targetType;
    Map<Schema.SObjectField, Schema.SObjectField> targetFieldBySourceFieldMap;

    public Translator() {
        this.targetFieldBySourceFieldMap = new Map<Schema.SObjectField, Schema.SObjectField>();
    }

    protected override void beforeConvert(SObject source) {
        // Since this acts as a cloner, then the target type will always be the same as the source's.
        this.targetType = source.getSObjectType();

        this.populateMapBasedOnQueriedFields(source);
     }

    protected override Schema.SObjectType getTargetSObjectType() {
        return this.targetType;
    }

    protected override Map<Schema.SObjectField, Schema.SObjectField> getTargetFieldBySourceFieldMap() {
        return this.targetFieldBySourceFieldMap;
    }

    protected override Object onPopulateField(SObject sourceRecord, SObjectField sourceField, Object dataToTransfer) { 
        if (sourceField.getDescribe().getType() != Schema.DisplayType.TEXTAREA &&
            sourceField.getDescribe().getType() != Schema.DisplayType.STRING) {
                return dataToTransfer;
        }

        String translatedData = translationMap.get((String)dataToTransfer);
        if (translatedData != null) {
            return translatedData;
        }

        return dataToTransfer;
    }

    protected override void afterConvert(SObject source, SObject resultRecord) { 
        String recordName = resultRecord.get('Name');
        if (String.isBlank(recordName)) {
            return;
        }

        resultRecord.put('Name', recordName + '_es');
    }

    private void populateMapBasedOnQueriedFields(SObject sourceRecord) {
        Map<String, Schema.SObjectField> mfields = 
            sourceRecord.getSObjectType().getDescribe().fields.getMap();

        for (String populatedFieldAsString : sourceRecord.getPopulatedFieldsAsMap().keySet()) {
            SObjectField populatedField = mfields.get(populatedFieldAsString);
            targetFieldBySourceFieldMap.put(populatedField, populatedField);
        }
    }
}
