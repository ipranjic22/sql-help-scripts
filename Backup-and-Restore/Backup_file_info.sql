/*
	Backup and Restore Tables
	https://docs.microsoft.com/en-us/sql/relational-databases/system-tables/backup-and-restore-tables-transact-sql?view=sql-server-ver15
	
	msdb.dbo.backupset
	https://docs.microsoft.com/en-us/sql/relational-databases/system-tables/backupset-transact-sql

	msdb.dbo.backupmediafamily
	https://docs.microsoft.com/en-us/sql/relational-databases/system-tables/backupmediafamily-transact-sql
*/

SELECT
	BS.backup_set_id AS ID
,	SUBSTRING(BMF.physical_device_name, 0, LEN(BMF.physical_device_name) - CHARINDEX('\', REVERSE(BMF.physical_device_name)) + 2) AS FileLocation
,	RIGHT(BMF.physical_device_name, CHARINDEX('\', REVERSE(BMF.physical_device_name)) - 1) AS BackupFileName
,	CASE
		WHEN BS.type = 'D' THEN 'FULL'
		WHEN BS.type = 'I' THEN 'DIFFERENTIAL'
		WHEN BS.type = 'L' THEN 'LOG'
	END AS BackupType
,	CASE
		WHEN BMF.device_type = 2 THEN 'Disk'
		WHEN BMF.device_type = 5 THEN 'Tape'
		WHEN BMF.device_type = 7 THEN 'Virtual device'
		WHEN BMF.device_type = 9 THEN 'Azure Storage'
		WHEN BMF.device_type = 105 THEN 'A permanent backup device'
	END AS StorageDevice
,	CONVERT(DATETIME2(0), BS.backup_start_date) AS DateStart
,	CONVERT(DATETIME2(0), BS.backup_finish_date) AS DateEnd
,	RIGHT('00' + CONVERT(VARCHAR(5), DATEDIFF(SECOND, BS.backup_start_date, BS.backup_finish_date) / 3600), 2) + ':'
	+ RIGHT('00' + CONVERT(VARCHAR(5), DATEDIFF(SECOND, BS.backup_start_date, BS.backup_finish_date) / 60 % 60), 2) + ':'
	+ RIGHT('00' + CONVERT(VARCHAR(5), DATEDIFF(SECOND, BS.backup_start_date, BS.backup_finish_date) % 60), 2) AS [Duration(HH:MM:SS)]
,	CONVERT(INT, BS.backup_size / 1014 / 1024) AS SizeMB
,	CONVERT(DECIMAL(10,2), BS.backup_size / 1024 / 1024 / 1024) AS SizeGB
,	CONVERT(INT, BS.compressed_backup_size / 1024 / 1024) AS CompressSizeMB
,	CONVERT(DECIMAL(10,2), BS.compressed_backup_size / 1024 / 1024 / 1024) AS CompressSizeGB
,	CONVERT(DECIMAL(5,2), BS.backup_size / BS.compressed_backup_size) AS CompressRatio
FROM
	msdb.dbo.backupset AS BS
	INNER JOIN msdb.dbo.backupmediafamily AS BMF
		ON BMF.media_set_id = BS.media_set_id
WHERE
	BS.[database_name] IN
	(
		'DatabaseName'
	)
	AND BS.is_copy_only = 0
	AND BS.[type] = 'D' --> Backup type: D, I, L
	AND BS.backup_finish_date > DATEADD(DAY, -30, GETDATE()) --> Last 30 days