
TRUNCATE TABLE ${tableName} WITH (PARTITIONS (${partitionNum}));
ALTER TABLE ${tableName}${tableSuffix} SWITCH PARTITION ${partitionNum} TO ${tableName} PARTITION ${partitionNum};
DROP TABLE ${tableName}${tableSuffix};
