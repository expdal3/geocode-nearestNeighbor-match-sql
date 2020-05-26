# Stored Procedure to search for nearest geo location ('Nearest Neighbor') in SQL 
Geocode (latitude and longiture) nearest neighbor matching with customisable number of neighbors and Km radius.

The T-SQL script create a stored procedure which return all nearest geo matches of a given lat/long pair, allowing for query user to specify how many neighbors and within how many Km radius as they like. The output of the stored procedure is a table with the look-up'd locations and theirs neighbors - from which then user can perform further lookup in other MSSQL platforms like SSRS, SSIS, SSAS or Power BI.

## Files

1. "NearestNeighbor-test and spatial datasets.sql": this contain script to populate test dataset and the Reference Spatial Dataset (RSD), both containt latitude and longitude location information. RSD includes Australian suburb level data in ACT, VIC and SA states.  Test dataset are five random high schools from these states.

2. "NearestNeighbor-procedures script and testing.sql": stored procedure script and it's application on the test dataset using RSD
The stored procedure take in the following parameters;
 * @g: (lookup location's geo data) the MSSQL's format for geography data (have a look at this [link](https://docs.microsoft.com/en-nz/sql/t-sql/spatial-geography/ogc-methods-on-geography-instances?view=sql-server-ver15) for more information. This is concatenated from the Latitude and Longitude columns of the RSD
 * @gid:  (lookup location's ID) the ID of the geo code above in the test dataset (returned in the output table to be used for subsequent table linking / lookup)
 * @gname: (lookup location's name): the name of the place being lookup for neighbors
 * @tablename: any database of neighbors spatial data, in this case RSD
 * @RefIDCol: the 'ID' (contain UID or business key) column of neighbors dataset
 * @RefNameCol: the Name column of neighbors dataset
 * @n: number of required neighbors, 1,2,3,4....
 * @distanceInMetre: the radius in meters, i.e. for 1Km radius, user will put 1000 here
 
 
