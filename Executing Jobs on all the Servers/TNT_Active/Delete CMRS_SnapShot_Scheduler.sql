USE [msdb]
GO

/****** Object:  Job [CMRS_Snapshot_Scheduler]    Script Date: 12/07/2012 17:34:25 ******/
DECLARE @jobId binary(16)

SELECT @jobId = job_id FROM msdb.dbo.sysjobs WHERE (name = N'CMRS_Snapshot_Scheduler')
IF (@jobId IS NOT NULL)
BEGIN
    EXEC msdb.dbo.sp_delete_job @jobId
END
