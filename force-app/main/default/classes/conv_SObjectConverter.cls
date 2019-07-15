public abstract class conv_SObjectConverter {
    public SObject convert(SObject sourceRecord) {
        this.beforeConvert(sourceRecord);

        SObject recordToReturn = this.getTargetSObjectType().newSObject();
        for (Schema.SObjectField sourceField : this.getTargetFieldBySourceFieldMap().keySet()) {
            Schema.SObjectField targetField = this.getTargetFieldBySourceFieldMap().get(sourceField);

            ConversionContext ctx = getConversionContext(sourceField.getDescribe().getType(), 
                targetField.getDescribe().getType());

            recordToReturn.put(targetField, ctx.getTransferableData(sourceRecord, sourceField));
        }

        this.afterConvert(sourceRecord, recordToReturn);

        return recordToReturn;
    }

    protected abstract Schema.SObjectType getTargetSObjectType();

    protected abstract Map<Schema.SObjectField, Schema.SObjectField> getTargetFieldBySourceFieldMap();

    protected virtual void beforeConvert(SObject source) { }

    protected virtual void afterConvert(SObject source, SObject resultRecord) { }

    private ConversionContext getConversionContext(Schema.DisplayType sourceType, Schema.DisplayType targetType) {
        // TODO: Allow for others to create their own converters and override these, for example for the translation use case
        if (sourceType == targetType) {
            return new SameContext();
        } else if (targetType == Schema.DisplayType.String || targetType == Schema.DisplayType.TextArea) {
            // TODO: Test out the other display types that are for strings, like emails
            return new AnyToStringContext();
        }

        // TODO: Throw exception
        return null;
    }

    public interface ConversionContext {
        Object getTransferableData(SObject sourceRecord, SObjectField sourceField);
    }

    public class SameContext implements ConversionContext {
        public Object getTransferableData(SObject sourceRecord, SObjectField sourceField) {
            return sourceRecord.get(sourceField);
        }
    }

    public class AnyToStringContext implements ConversionContext {
        public Object getTransferableData(SObject sourceRecord, SObjectField sourceField) {
            return String.valueOf(sourceRecord.get(sourceField));
        }
    }
}
