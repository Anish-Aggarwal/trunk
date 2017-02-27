USE [msdb]
GO

/****** Object:  Job [CMRS_ReconMessageAcks_Scheduler]    Script Date: 01/07/2013 14:14:31 ******/
DECLARE @jobId binary(16)

SELECT @jobId = job_id FROM msdb.dbo.sysjobs WHERE (name = N'CMRS_ReconMessageAcks_Scheduler')
IF (@jobId IS NOT NULL)
BEGIN
    EXEC msdb.dbo.sp_delete_job @jobId
END


USE [msdb]
GO

/****** Object:  Job [CMRS_ReconMessageAcks_Scheduler]    Script Date: 01/07/2013 14:14:31 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 01/07/2013 14:14:31 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'CMRS_ReconMessageAcks_Scheduler', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'CMRS_ReconMessageAcks_Scheduler', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'cmrs_automation', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Set the trigger for Reconciliation of Message Acks]    Script Date: 01/07/2013 14:14:31 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Set the trigger for Reconciliation of Message Acks', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec [TnT].[udsp_ReconMessageAcknowledgements]', 
		@database_name=N'CMRS_TRACK_N_TRACE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'ReconMessageAcks Schedule', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=30, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20121127, 
		@active_end_date=99991231, 
		@active_start_time=100500, 
		@active_end_time=235959, 
		@schedule_uid=N'0ce7f241-12a4-4695-b655-8b97766fed4e'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


