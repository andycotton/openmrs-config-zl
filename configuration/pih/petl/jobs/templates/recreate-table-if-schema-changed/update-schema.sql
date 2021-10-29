DECLARE @NumChanges INT;

SET @NumChanges = (
    SELECT count(*)
    FROM sys.dm_exec_describe_first_result_set (N'SELECT * FROM ${tableName}${tableSuffix}', NULL, 0) t1
             FULL OUTER JOIN  sys.dm_exec_describe_first_result_set (N'SELECT * FROM ${tableName}', NULL, 0) t2 ON t1.name = t2.name
    WHERE ((isnull(t1.name, '') != isnull(t2.name, '')) OR (isnull(t1.system_type_name, '') != isnull(t2.system_type_name, '')))
)
;

IF (@NumChanges > 0)
BEGIN
    DECLARE @SQL NVARCHAR(1000);

    IF OBJECT_ID('${tableName}') IS NOT NULL
        BEGIN
            DROP TABLE ${tableName};
        END

    EXEC sp_rename '${tableName}${tableSuffix}', '${tableName}';
END

IF OBJECT_ID('${tableName}${tableSuffix}') IS NOT NULL
BEGIN
    DROP TABLE ${tableName}${tableSuffix};
END
