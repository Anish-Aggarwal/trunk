/* For security reasons the login is created disabled and with a random password. */
/****** Object:  Login [NagiosMon]    Script Date: 07/02/2014 09:56:56 ******/
CREATE LOGIN [NagiosMon] WITH PASSWORD=N'Nagio$m0n', DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO

EXEC sys.sp_addsrvrolemember @loginame = N'NagiosMon', @rolename = N'sysadmin'
GO
