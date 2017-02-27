EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'CMRS_MOCK_ICE'
USE [master]
GO
DROP DATABASE [CMRS_MOCK_ICE]
GO

DECLARE @drive VARCHAR(30)
SET @drive = '$(DriveParam)'

Declare @sql nvarchar(4000)
set @sql = 'RESTORE DATABASE [CMRS_MOCK_ICE] FROM  DISK = N''' + @drive + '\CMRS_Automation\MockIce\DataBase\MockIce.bak'' WITH  FILE = 1,  MOVE N''MockICE'' TO N''' + @drive + '\SQL Data Files\MockICE.mdf'',  MOVE N''MockICE_log'' TO N'''+ @drive+'\SQL Data Files\MockIce_1.ldf'',  NOUNLOAD,  REPLACE,  STATS = 10'

--print @sql
exec (@sql)

GO