USE CMRS_TRACK_N_TRACE
GO
DECLARE @servername VARCHAR(30)
SET @servername = '$(ServerName)'

update tnt.HttpQueryParameters
set URL = 'https://' + @servername + '/Sapient.Cmrs.MockIceTradeVault/Trade.aspx'