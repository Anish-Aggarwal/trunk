SET NOCOUNT ON
SELECT Top 1 [JobStatus] 
      
  FROM [CMRS_TRACK_N_TRACE].[TnT].[JobHeader]
  order by ProcessStartDateTime desc