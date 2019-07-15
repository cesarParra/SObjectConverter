public abstract class conv_SObjectConverter {
    public class ConversionException extends Exception { } 

    private List<ConversionContext> ctxs;

    public conv_SObjectConverter() {
        this.ctxs = new List<ConversionContext>();
        addConversionContext(new SameContext());
        addConversionContext(new AnyToStringContext());
        addConversionContext(new NumberToBoolean());
        addConversionContext(new StringToBoolean());
    }

    public void addConversionContext(ConversionContext ctx) {
        if (this.ctxs.isEmpty()) {
            this.ctxs.add(ctx);
            return;
        }
        // Adding to the begining of the list to allow for custom contexts 
        // to override the defaults when ctxs is being looped through.
        this.ctxs.add(0, ctx);
    }

    /**
     * Converts the source record into a new record, transfering field data.
     */
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
        for (ConversionContext currentContext : this.ctxs) {
            if (currentContext.meetsContextCriteria(sourceType, targetType)) {
                return currentContext;
            }
        }

        throw new ConversionException('No ConversionContext was found to allow converting between the 2 field types.');
    }

    // TODO: Unit test all remaining default contexts
    public interface ConversionContext {
        Object getTransferableData(SObject sourceRecord, SObjectField sourceField);
        Boolean meetsContextCriteria(Schema.DisplayType sourceFieldType, Schema.DisplayType targetFieldType);
    }

    public class SameContext implements ConversionContext {
        public Object getTransferableData(SObject sourceRecord, SObjectField sourceField) {
            return sourceRecord.get(sourceField);
        }

        public Boolean meetsContextCriteria(Schema.DisplayType sourceFieldType, Schema.DisplayType targetFieldType) {
            return sourceFieldType == targetFieldType;
        }
    }

    public class AnyToStringContext implements ConversionContext {
        public Object getTransferableData(SObject sourceRecord, SObjectField sourceField) {
            return String.valueOf(sourceRecord.get(sourceField));
        }

        public Boolean meetsContextCriteria(Schema.DisplayType sourceFieldType, Schema.DisplayType targetFieldType) {
            return targetFieldType == Schema.DisplayType.STRING || 
                targetFieldType == Schema.DisplayType.TEXTAREA;
        }
    }

    public class NumberToBoolean implements ConversionContext {
        public Object getTransferableData(SObject sourceRecord, SObjectField sourceField) {
            if (Integer.valueOf(sourceRecord.get(sourceField)) == 0) {
                return false;
            }
            return true;
        }

        public Boolean meetsContextCriteria(Schema.DisplayType sourceFieldType, Schema.DisplayType targetFieldType) {
            return (sourceFieldType == Schema.DisplayType.LONG || 
                sourceFieldType == Schema.DisplayType.CURRENCY ||
                sourceFieldType == Schema.DisplayType.DOUBLE ||
                sourceFieldType == Schema.DisplayType.INTEGER) &&
                targetFieldType == Schema.DisplayType.BOOLEAN;
        }
    }

    public class StringToBoolean implements ConversionContext {
        public Object getTransferableData(SObject sourceRecord, SObjectField sourceField) {
            String sourceValue = String.valueOf(sourceRecord.get(sourceField)).toLowerCase();
            if (sourceValue == 'true' || sourceValue == 'yes') {
                return true;
            } else if (sourceValue == 'false' || sourceValue == 'no') {
                return false;
            }

            return null;
        }

        public Boolean meetsContextCriteria(Schema.DisplayType sourceFieldType, Schema.DisplayType targetFieldType) {
            return (sourceFieldType == Schema.DisplayType.STRING || 
                sourceFieldType == Schema.DisplayType.TEXTAREA) && 
                targetFieldType == Schema.DisplayType.BOOLEAN;
        }
    }
}
