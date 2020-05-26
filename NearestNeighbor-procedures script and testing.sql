--------------------------------------------------------------------------------------
--------------------CREATE THE NEAREST NEIGHBOR PROCURES------------------------

IF object_id('nearestNeighbor') IS NOT NULL --check if a same procedure has been created
DROP PROCEDURE dbo.nearestNeighbor 
GO 
------------------PROCEDURE SYNTAX------------------------------------------------------
CREATE PROCEDURE dbo.nearestNeighbor @g nvarchar(255), @gid int, @gname nvarchar(255), --The lookup location's Geo, associated ID and Name of that location
@TableName nvarchar(100), @RefIDCol nvarchar(255), @RefNameCol nvarchar(255), --The reference table with Lat/Long and the ID and Name columns of each of these Lat/Long
@n int, @distanceInMetre int -- @n is how many nearest neightbor to return, @distanceInMeter: specify the radius
AS
DECLARE @Search nvarchar(100) = '';
SET @gname = REPLACE(@gname, '''', ''''''); --Handle any Single quote inside @gname (e.g. O'Sullivan)
declare @sql NVARCHAR(MAX) =
'
EXEC dbo.dropExistTable ''cte''

Select TOP('+CAST(@n as nvarchar(255))+') f.SpatialLocation.ToString() as [MatchedSpatialLocation]
, f.MatchedLocID
, f.MatchedLocName
, f.MatchedLocStateCode,
PlaceID = ' + CAST(@gid as nvarchar(255))+ ', PlaceName = ''' + @gname
+''' INTO cte
from
	(select a.'+ @RefIDCol + ' as MatchedLocID
	,a.'+ @RefNameCol + ' as MatchedLocName
	,a.StateCode as MatchedLocStateCode 
	, geography::STGeomFromText(''POINT('' + CAST(a.Longitude as nvarchar(255)) + '' '' + CAST(a.Latitude as nvarchar(255)) + '')'',4326) AS SpatialLocation
	from ' + @TableName +' a) as f
WHERE f.SpatialLocation.STDistance( ''' + CONVERT(nvarchar(255),geography::STGeomFromText(@g,4326) ) + ''') IS NOT NULL
AND f.SpatialLocation.STDistance(''' + CONVERT(nvarchar(255),geography::STGeomFromText(@g,4326) ) + ''')< ' + CAST(@distanceInMetre as nvarchar(255))
+'ORDER BY f.SpatialLocation.STDistance(''' + CONVERT(nvarchar(255),geography::STGeomFromText(@g,4326) ) + ''')
'
EXEC sp_executesql @sql
GO

--------------------------------------------------------------------------------------
--------------------RUN A WHILE LOOP THROUGH THE TEST DATASETS------------------------
--Make sure existing tables are dropped
EXEC dbo.dropExistTable 'TestNearestNeighborQuery'
EXEC dbo.dropExistTable 'cte'
WAITFOR DELAY '00:00:01'
-- Declare & init (2008 syntax)
DECLARE @LookupID INT = 0, @LookupName nvarchar(255) = '', @LookUpGeo nvarchar(255) = ''
--Create the final table if not exists --
CREATE TABLE TestNearestNeighborQuery (
PlaceID int
,PlaceName nvarchar(255)
,MatchedSpatialLocation nvarchar(255)
,MatchedLocID int
,MatchedLocName nvarchar(255)
,MatchedLocStateCode nvarchar(255)
);
-- Iterate over all customers
WHILE (1 = 1)
BEGIN
-- Get next customerId
SELECT TOP 1 @LookupID = t.ID, @LookupName = t.Name,
@LookUpGeo = ('POINT(' + CAST(t.long as nvarchar(255)) + ' ' + CAST(t.lat as nvarchar(255)) + ')')
FROM [dbo].[TestGeo] t
WHERE t.ID > @LookupID
ORDER BY t.ID

-- Exit loop if no more customers
IF @@ROWCOUNT = 0 BREAK;
--PRINT CAST(@SchoolID AS nvarchar(255)) + @SchoolName
-- call the proc
EXEC dbo.nearestNeighbor @g= @LookUpGeo, @gid = @LookupID, @gname = @LookupName
, @TableName = '[dbo].[LookupGeo]', @RefIDCol = 'SuburbID', @RefNameCol = 'SuburbName'
, @n = 2, @distanceInMetre = 20000

--insert the found result into the outcome table
INSERT INTO TestNearestNeighborQuery (PlaceID, PlaceName, MatchedSpatialLocation, MatchedLocID, MatchedLocName, MatchedLocStateCode)
SELECT PlaceID, PlaceName, MatchedSpatialLocation, MatchedLocID, MatchedLocName, MatchedLocStateCode FROM cte

END

Select * from TestNearestNeighborQuery