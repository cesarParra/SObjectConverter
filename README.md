# Apex SObjectConverter

Apex library to assist with converting between different SObjects or cloning records.

## Basics

A single class is in charge of orchestrating any record conversion or cloning operation, the conv_SObjectConverter.

To create a custom converter the `conv_SObjectConverter` should be extended and it's 2 abstract methods implemented:

```java
public class MyCustomLeadToAccountConverter extends conv_SObjectConverter {
  protected override Schema.SObjectType getTargetSObjectType() {
        return Account.SObjectType;
    }

    protected override Map<Schema.SObjectField, Schema.SObjectField> getTargetFieldBySourceFieldMap() {
        return new Map<Schema.SObjectField, Schema.SObjectField> {
            Lead.Description => Account.Description, 
            Lead.NumberOfEmployees => Account.NumberOfEmployees
        };
    }
}
```

Some additional optional methods are provided to create more powerful conversions:

```java
protected virtual void beforeConvert(SObject source);
```

Allows you to hook into the conversion process before it begins, giving you the source SObject that will be converted.

```java
protected virtual void afterConvert(SObject source, SObject resultRecord);
```

Allows you to hook into the conversion process after it ends, giving you the source converted SObject as well as the resulting record.

```java
protected virtual Object onPopulateField(SObject sourceRecord, SObjectField sourceField, Object dataToTransfer);
```

Called on each field being converted. Allows you to override the value (dataToTransfer) that will be populated on the target field.

## Conversion Contexts

To power how fields are converted, `conv_SObjectConverter` uses Conversion Contexts (`conv_SObjectConverter.ConversionContext`).

These take care of converting data between fields which types might not match from the defined getTargetFieldBySourceFieldMap.

By default the following Conversion Contexts are used by the converter:

| Conversion Context | Description |
| ------------- | ------------- |
| Same Context  | Converts fields that are of the same type.  |
| Any To String  | Converts any data type to a String using String.valueOf() |
| Number To Boolean  | Converts 0 to false, and any other number to true |
| String To Boolean  | Converts the words "yes" and "true" (case insensitive) to true, and "no" and "false" to false. |

### Custom Conversion Contexts

You can create your custom `ConversionContext` implementations which allows you to create more types of data conversions or override the default ones.

To create a custom context you can do the following:
1.  Create an implementation of `conv_SObjectConverter.ConversionContext`

2 methods should be implemented: 

#### getTransferableData

```java
Object getTransferableData(SObject sourceRecord, SObjectField sourceField);
```

Implementation of the logic applied when converting from one type to another. For example, in the case of the Any To String implementation, this is 

```java
public Object getTransferableData(SObject sourceRecord, SObjectField sourceField) {
  return String.valueOf(sourceRecord.get(sourceField));
}
```

#### meetsContextCriteria

```java
Boolean meetsContextCriteria(Schema.DisplayType sourceFieldType, Schema.DisplayType targetFieldType);
```

Determines whether the context applies based on the field types.

2. Register your context when your your `conv_SObjectConverter`.
   
```java
// Assuming we have a custom conv_SObjectConverter.ConversionContext called CustomContext.
new conv_SObjectConverter()
  .addConversionContext(new CustomContext())
  .convert(myRecord);
```


## Example - Translating Records

An example implementation of a converter to translate record field values is provided in the `/sample` module. 

That example shows the capabilities of cloning a record rather than converting by returning the same received `SObjectType` as the target and using all populated fields for the map. Using the `afterConvert` method the resulting SObject's name is renamed with an `_es` suffix to denote that it is a translated version of a different record.

```java
public with sharing class Translator extends conv_SObjectConverter {
    ...
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
      ...
    }

    ...
}
```