USE [msdb]
GO

DECLARE @jobId binary(16)

SELECT @jobId = job_id FROM msdb.dbo.sysjobs WHERE (name = N'DTA Purge and Archive (BizTalkDTADb)')
IF (@jobId IS NOT NULL)
BEGIN
    EXEC msdb.dbo.sp_update_jobstep @jobId, @step_id=1, 
		@command=N'declare @dtLastBackup datetime set @dtLastBackup = GetUTCDate() exec dtasp_PurgeTrackingDatabase 1, 0, 1, @dtLastBackup'
END
GO
