USE [msdb]
GO
exec msdb..sp_update_job @job_name = 'DTA Purge and Archive (BizTalkDTADb)', @enabled = 1 --Enable
Go
