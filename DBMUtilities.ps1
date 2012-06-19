<#
.SYNOPSIS
    Create a new SMOConnection Object.

.DESCRIPTION
    The Get-SMOConnection creates new SMO Connection to the SQL Server instance
	and returns the connection object to the calling function or script.
 
 .PARAMETER sqlServer
	Name of the SQL Server instance in the following format: SQLServer\InstanceName
	
	Required                                          true
	Position                                            named
	Default value                                 
	Accept pipeline input                 false
	Accept wildcard characters       false

.PARAMETER appName
	Name of the connection, as visible in SQL Server connections.
	
	Required                                         false
	Position                                           named
	Default value                                 'Powershell-UserName@ComputerName' 
	Accept pipeline input                false
	Accept wildcard characters     false

.PARAMETER commandTimeout
	Timeout value of the SMO Connection object
	
	Required     false
	Position     named
	Default value     10
	Accept pipeline input     false
	Accept wildcard characters     false

.EXAMPLE
   	Get-SMOConnection where appName and commandTimeout are defaults
		Get-SMOConnection "DSD03SQL8\SX01DBA01"

.EXAMPLE
   	Get-SMOConnection where commandTimeout are defaults
		Get-SMOConnection  -sqlServer "DSD03SQL8\SX01DBA01" -appName "Powershell-TestConnection"

.EXAMPLE
   	Get-SMOConnection where all parameter are specified and the command has unlimited time to finish
		Get-SMOConnection  -sqlServer "DSD03SQL8\SX01DBA01" -appName "Powershell-TestConnection" -commandTimeout 0

.NOTES
    Scripts to manage SQL Server
#>
Function Get-SMOConnection {
	Param (
			$SqlServer = $(throw "Specify the server to connect in following format: ServerName\InstanceName"),
			$AppName = "PowerShell-" + "$env:username" +"`@" +  "$env:computername",
			[int]$CommandTimeout=10
		)
	
	Write-Debug "Function: Get-SMOConnection $sqlServer $connectionName $commandTimeout"
	try{
		
		If ( Test-Path Variable:\smoConn ) {
			$smoConn.ConnectionContext.Disconnect()
		} Else {
			$smoConn = [Microsoft.SqlServer.Management.Smo.Server] $SqlServer
		}
		
		$smoConn.ConnectionContext.ApplicationName = $AppName
		$smoConn.ConnectionContext.ConnectTimeout = $CommandTimeout
		$smoConn.ConnectionContext.Connect()
		$smoConn
	}catch{
		$_ | fl * -Force #Being lazy. Need to do proper error handling.
	}
}


#Initiate forced failover
Function Initiate-ForcedFailover
{
	Param($Mirror, $dbName)
	try{
		
		$dbConn = Get-SmoConnection -SqlServer $Mirror -CommandTimeout 0
		$dbToForce = $dbConn.Databases[$dbName]
		$dbToForce.ChangeMirroringState([Microsoft.SqlServer.Management.Smo.MirroringOption]::ForceFailoverAndAllowDataLoss)
		<# Regular way of doing this
			$queryToRun = "ALTER DATABASE $dbName SET PARTNER FORCE_SERVICE_ALLOW_DATA_LOSS;"
			$dbToForce.ExecuteNonQuery($queryToRun)
		#>
		$dbConn.ConnectionContext.Disconnect()
	}catch{
		$_|fl * -Force
	}
}

#Initiate Graceful failover
Function Initiate-GracefulFailover
{
	Param ($Primary, $Mirror, $dbName)
	try{
		#Being optimistically greedy and getting the connection object and database object at the begining.
		$primarySrvrConn = Get-SMOConnection -SqlServer $Primary -CommandTimeout 0
		$primaryDB = $primarySrvrConn.Databases[$dbName]
		
		$mirrorSrvrConn = Get-SMOConnection -SqlServer $Mirror -CommandTimeout 0
		$mirrorDB = $mirrorSrvrConn.Databases[$dbName]
		
		#check database role
		if($primaryDB.Properties["MirroringRole"].Value -eq [Microsoft.SqlServer.Management.Smo.MirroringRole]::Principal){
			#Check the mirroring statusP: $mirrorStatus = $primaryDB.MirroringStatus
			do{
				Start-Sleep -Seconds 15
				$mirrorStatus = $primaryDB.MirroringStatus
				
			} until ($mirrorStatus -eq [Microsoft.SqlServer.Management.Smo.MirroringStatus]::Synchronized)
			
			if($mirrorStatus -eq [Microsoft.SqlServer.Management.Smo.MirroringStatus]::Synchronized){
				#Setting Transaction safety to Full on Primary
				$primaryDB.ExecuteNonQuery("Use master; ALTER DATABASE $dbName SET SAFETY FULL;")
				#Failing over
				$dbToForce.ChangeMirroringState([Microsoft.SqlServer.Management.Smo.MirroringOption]::Failover)
				#$primaryDB.ExecuteNonQuery("Use master; ALTER DATABASE $dbName SET PARTNER FAILOVER;")
				#Setting transaction safety off on Mirror
				$mirrorDB.ExecuteNonQuery("Use master; ALTER DATABASE $dbName SET SAFETY OFF;")
			}
		}else{
				Write-Host "The role of the server: $Primary, is not what was expected. Kindly validate the server name." -Fore Red
		}
		
		$primarySrvrConn.ConnectionContext.Disconnect()
		$mirrorSrvrConn.ConnectionContext.Disconnect()
	}catch{
		$_|fl * -Force
	}
}

#get the current status of the mirror
Function Get-MirrorStatus{
 Param($Primary, $dbName)
 try{
	#Being optimistically greedy and getting the connection object and database object at the begining.
	$primarySrvrConn = Get-SMOConnection -SqlServer $Primary -CommandTimeout 0
	$primaryDB = $primarySrvrConn.Databases[$dbName]
	
	#check database role
	if($primaryDB.Properties["MirroringRole"].Value -eq [Microsoft.SqlServer.Management.Smo.MirroringRole]::Principal){
		#use mode=0 to only get the last row
		$qryString=	"EXEC msdb..sp_dbmmonitorresults  $dbName,  0, 0"
		[System.Data.DataSet]$resSet = $primaryDB.ExecuteWithResults($qryString)
		foreach($row in $resSet.Tables[0]){
			#$timeRecorded = $row.time_recorded	#$timeBehind = $row.time_behind
			$timeLag = ((Get-Date $row.time_recorded)-(Get-Date $row.time_behind)).Minutes
			$mirrorSrvrName = $primaryDB.MirroringPartnerInstance
			Write-Host "The mirror: $mirrorSrvrName for current primary: $Primary is behind by: $timeLag Minutes"
		}
	}else{
		Write-Host "The role of the server: $Primary, is not what was expected. Kindly validate the server name." -Fore Red
	}
	
	$primarySrvrConn.ConnectionContext.Disconnect()
 }catch{
 }
 
}
<#
	$endPoints.EnumEndpoints([Microsoft.SqlServer.Management.Smo.EndPointType]::DatabaseMirroring)
	Soap -> The HTTP endpoint type is SOAP.
	TSql -> The HTTP endpoint type is Transact-SQL.
	ServiceBroker -> The HTTP endpoint type is SQL Server Service Broker.
	DatabaseMirroring -> The HTTP endpoint type is database mirroring.
	
	[Void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo")  
	[Void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO")  
	[Void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoExtended")  

#>