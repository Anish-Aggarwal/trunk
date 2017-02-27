Const ADS_UF_DONT_EXPIRE_PASSWD = &h10000 

strDomainOrWorkgroup = "sapient" 
strComputer = "dluaagg2185993" 
strUser = "s_cmrsadmin" 

Set objUser = GetObject("WinNT://" & strDomainOrWorkgroup & "/" & _ 
    strComputer & "/" & strUser & ",User") 

objUserFlags = objUser.Get("UserFlags") 
objPasswordExpirationFlag = objUserFlags OR ADS_UF_DONT_EXPIRE_PASSWD 
objUser.Put "userFlags", objPasswordExpirationFlag  
objUser.SetInfo