SET NOCOUNT ON
SELECT A.MessageStageWiseDetailId, A.StageStatus
  FROM [CMRS_TRACK_N_TRACE].[TnT].[MessageStageWiseDetail]  A
  
  join [CMRS_TRACK_N_TRACE].[TnT].[MessageHeaderStagewiseDetailMap] B
  on A.[MessageStageWiseDetailId] = B.[MessageStageWiseDetailId]
  where
  B.[MessageHeaderId] in
  (select top 1 [MessageHeaderId] from [CMRS_TRACK_N_TRACE].[TnT].[MessageHeader] order by [CreationDateTime] desc )