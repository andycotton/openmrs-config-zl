IF OBJECT_ID('${tableName}${tableSuffix}') IS NOT NULL
BEGIN
    DROP TABLE ${tableName}${tableSuffix};
END