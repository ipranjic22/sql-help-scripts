DECLARE @Database VARCHAR(256) = 'IsupiMatica'

SELECT
	'RESTORE LOG ' + @Database + ' FROM DISK = N''' + BMF.physical_device_name + ''' WITH FILE = 1, NORECOVERY, NOUNLOAD, STATS = 5' AS LOG_Restore_Script
FROM
	msdb.dbo.backupset AS BS
	INNER JOIN msdb.dbo.backupmediafamily AS BMF
		ON BS.media_set_id = BMF.media_set_id
WHERE
	BS.[type] = 'L'
	AND BS.[database_name] = @Database
	/* Last 24h */
	AND BS.backup_finish_date > DATEADD(DAY, -1, GETDATE())
	/* LOG backups after last DIFF backup  */
	AND BS.backup_start_date >
	(
		SELECT
			MAX(backup_start_date) AS backup_finish_date
		FROM
			msdb.dbo.backupset
		WHERE
			[type] = 'I'
			AND [database_name] = @Database
	)