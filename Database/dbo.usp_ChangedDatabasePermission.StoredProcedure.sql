/****** Object:  StoredProcedure [dbo].[usp_ChangedDatabasePermission]    Script Date: 07/09/2008 12:08:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_ChangedDatabasePermission]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_ChangedDatabasePermission]
@captureDT1 datetime, @captureDT2 datetime
AS
SET NOCOUNT ON
IF @captureDT1 > @captureDT2
BEGIN
	RAISERROR (''@captureDT1 is Greater Than @captureDT2'',16,1)
END;

WITH Added AS
(
	SELECT PermissionState, Server, dbname, Grantee, PermissionType, member
	FROM dbo.vw_DatabasePermissionMember
	WHERE timestamp = @captureDT2
	EXCEPT 
	SELECT PermissionState, Server, dbname, Grantee, PermissionType, member
	FROM dbo.vw_DatabasePermissionMember
	WHERE timestamp = @captureDT1
),
Removed AS
(
	SELECT PermissionState, Server, dbname, Grantee, PermissionType, member
	FROM dbo.vw_DatabasePermissionMember
	WHERE timestamp = @captureDT1
	EXCEPT 
	SELECT PermissionState, Server, dbname, Grantee, PermissionType, member
	FROM dbo.vw_DatabasePermissionMember
	WHERE timestamp = @captureDT2
)
SELECT *, ''Added'' AS ChangeType FROM Added
UNION
SELECT *, ''Removed'' AS ChangeType FROM Removed;
' 
END
GO
