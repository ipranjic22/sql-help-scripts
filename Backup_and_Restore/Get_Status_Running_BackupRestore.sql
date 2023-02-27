SELECT
	r.session_id AS SessionID
,	r.command AS Command
,	CONVERT(NUMERIC(6,2), r.percent_complete) AS [% Complete]
,	GETDATE() AS CurrentTime
,	CONVERT(VARCHAR(20), DATEADD(ms, r.estimated_completion_time, GETDATE()), 20) AS EstimatedCompletionTime
,	CONVERT(NUMERIC(32,2), r.total_elapsed_time / 1000.0 / 60.0) AS ElapsedMin
,	CONVERT(NUMERIC(32,2), r.estimated_completion_time / 1000.0 / 60.0) AS EstimatedMin
,	CONVERT(NUMERIC(32,2), r.estimated_completion_time / 1000.0 / 60.0 / 60.0) AS EstimatedHours
,	(
		SELECT
			CONVERT(VARCHAR(1000), SUBSTRING(TEXT, r.statement_start_offset / 2, CASE WHEN r.statement_end_offset = - 1 THEN 1000 ELSE (r.statement_end_offset - r.statement_start_offset) / 2 END)) AS StatementText
		FROM
			sys.dm_exec_sql_text(sql_handle)
	) AS StatementText
FROM
	sys.dm_exec_requests r
WHERE
	command LIKE 'RESTORE%'
	or  command LIKE 'BACKUP%'