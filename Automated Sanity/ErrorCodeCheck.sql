SET NOCOUNT ON
DECLARE @errorId varchar(20)
SET @errorId = '$(ErrorCodeId)'
--select @errorId
SELECT [ErrorMessage]
      
  FROM [CMRS_TRACK_N_TRACE].[TnT].[ExceptionDetail]
  where Cast( [MessageStageWiseDetailId] as varchar(20)) = @errorId