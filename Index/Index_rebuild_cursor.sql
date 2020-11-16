DECLARE @TableName VARCHAR(255)
DECLARE @sql NVARCHAR(500)
DECLARE @IndexName VARCHAR(255)

DECLARE TableCursor CURSOR FOR
SELECT
	X.TableName
,	X.IndexName
FROM
	(
		SELECT
			'[' + OBJECT_SCHEMA_NAME(TBL.[object_id]) + ']' + '.' + '[' + TBL.[name] + ']' AS TableName
		,	IX.[name] AS IndexName
		from
			sys.dm_db_index_physical_stats (DB_ID(), null, null, null, null) AS IXS
			INNER JOIN sys.tables AS TBL
				ON TBL.[object_id] = IXS.[object_id]
			INNER JOIN sys.schemas AS SCH
				ON SCH.[schema_id] = TBL.[schema_id]
			INNER JOIN sys.indexes AS IX
				ON IX.[object_id] = IXS.[object_id]
				AND IX.index_id = IXS.index_id
		WHERE
			IXS.database_id = DB_ID()
			AND IXS.avg_fragmentation_in_percent > 0
	) AS X

OPEN TableCursor

FETCH NEXT FROM TableCursor INTO @TableName, @IndexName

WHILE @@FETCH_STATUS = 0
BEGIN

	SET @sql = 'ALTER INDEX ' + '[' + @IndexName + ']' + ' ON ' + @TableName + ' REBUILD'
	
	PRINT @sql
	
	EXECUTE (@sql)

	FETCH NEXT FROM TableCursor INTO @TableName, @IndexName
END

CLOSE TableCursor
DEALLOCATE TableCursor
GO