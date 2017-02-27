USE [master]

GO
IF OBJECT_ID('tempdb..#mem') IS NOT NULL DROP TABLE #mem
GO

DECLARE 
@memInMachine DECIMAL(9,2)
,@sql VARCHAR(1000)

CREATE TABLE #mem(mem DECIMAL(9,2))

IF CAST(LEFT(CAST(SERVERPROPERTY('ResourceVersion') AS VARCHAR(20)), 1) AS INT) = 9
  SET @sql = 'SELECT physical_memory_in_bytes/(1024*1024*1024.) FROM sys.dm_os_sys_info'
ELSE 
   IF CAST(LEFT(CAST(SERVERPROPERTY('ResourceVersion') AS VARCHAR(20)), 2) AS INT) >= 11
     SET @sql = 'SELECT physical_memory_kb/(1024*1024.) FROM sys.dm_os_sys_info'
   ELSE
     SET @sql = 'SELECT physical_memory_in_bytes/(1024*1024*1024.) FROM sys.dm_os_sys_info'

SET @sql = 'DECLARE @mem decimal(9,2) SET @mem = (' + @sql + ') INSERT INTO #mem(mem) VALUES(@mem)'
PRINT @sql
EXEC(@sql)
SET @memInMachine = (SELECT MAX(mem) FROM #mem)

declare @memrest int

set @memrest= @memInMachine* 665.6

-- Set max server memory limit

EXEC sp_configure 'show advanced options', 1

RECONFIGURE WITH OVERRIDE

 

EXEC sp_configure 'max server memory (MB)', @memrest

RECONFIGURE WITH OVERRIDE

 

-- Check the setting

EXEC sp_configure 'max server memory (MB)'

