/*HW DATA - Comp Spend*/
SELECT * FROM mmm.mmm_comp_media_raw;

SELECT DISTINCT a.`Week`
FROM mmm.mmm_comp_media_raw a
LEFT JOIN mmm.mmm_date_metadata b
ON a.`Week` = b.`Week`
WHERE b.`Week` IS NULL
;

CREATE TABLE mmm.mmm_comp_media_transformed
(
SELECT `Week`
,ROUND(SUM(`Competitive Media Spend`),0) AS `Comp Spend`
FROM mmm.mmm_comp_media_raw
GROUP BY `Week`
);

/*HW DATA - Event*/
SELECT * FROM mmm.mmm_event_raw;

SELECT * 
FROM mmm.mmm_event_raw a
RIGHT JOIN mmm.mmm_date_metadata b
ON a.`Day` = b.`Day`
WHERE b.`Week` = '2014-07-07 00:00:00'
ORDER BY b.`Day`
;

CREATE TABLE mmm.mmm_event_transformed
(
SELECT 
b.`Week`
,ROUND(COALESCE(AVG(`Sales Event`),0),0) AS `SalesEvent`
FROM mmm.mmm_event_raw a
RIGHT JOIN mmm.mmm_date_metadata b
ON a.`Day` = b.`Day`
GROUP BY b.`Week`
)
;

SELECT DISTINCT DATE_ADD(`Day`, INTERVAL -Weekday(`Day`) DAY)
FROM mmm.mmm_event_raw
;

/*HW Data - Econ*/
SELECT * FROM mmm.mmm_econ_raw;

CREATE TABLE mmm.mmm_econ_transformed
(
SELECT 
b.`Week`
,ROUND(AVG(`Value`),1) AS `Unemployment Rate`
FROM mmm.mmm_econ_raw a
LEFT JOIN mmm.mmm_date_metadata b
ON a.`Date` = b.`Month`
GROUP by b.`Week`
);

/*HW - SQL*/
SELECT 
* 
FROM mmm.mmm_sales_transformed
WHERE Sales > 250000;

SELECT
a.*
FROM mmm.mmm_sales_transformed a
LEFT JOIN mmm.mmm_sales_transformed b
ON a.`Week` = DATE_ADD(b.`Week`, INTERVAL 7 DAY)
WHERE a.Sales > b.Sales
;

CREATE TABLE mmm.mmm_quarterlysales
(
SELECT
YEAR(`Week`) AS Year
,QUARTER(`Week`) AS Quarter
,SUM(`Sales`) AS QuarterlySales
FROM mmm.mmm_sales_transformed
GROUP BY
YEAR(`Week`)
,QUARTER(`Week`)
);

SELECT * FROM mmm.mmm_quarterlysales;

SELECT *
FROM mmm.mmm_quarterlysales
WHERE QuarterlySales IN (SELECT MAX(QuarterlySales) FROM mmm.mmm_quarterlysales GROUP BY `Year`)
;

/*MMM Data - Offline*/
SELECT * FROM mmm.mmm_offline_raw;

CREATE TABLE mmm.mmm_offline_transformed
(
SELECT
`Date`
,ROUND(SUM(`TV GRP`/100 * `TOTAL HH`)/SUM(`TOTAL HH`)*100,1) AS `National TV GRP`
,ROUND(SUM(`Magazine GRP`/100 * `TOTAL HH`)/SUM(`TOTAL HH`)*100,1) AS `Magazine GRP`
FROM mmm.mmm_offline_raw a
LEFT JOIN mmm.mmm_dma_hh b
ON a.`DMA` = b.`DMA Name`
GROUP BY `Date`
)
;

SELECT * FROM mmm.mmm_offline_transformed;

/*MMM Data - Display*/
SELECT * FROM mmm.mmm_dcmdisplay_2015;

SELECT DISTINCT `Campaign Name` FROM mmm.mmm_dcmdisplay_2015;

CREATE TABLE mmm.mmm_dcmdisplay_transformed
(
SELECT 
`Date`
,SUM(CONVERT(REPLACE(`Served Impressions`,',',''), SIGNED INTEGER)) AS `DisplayImpression`
,SUM(IF(`Campaign Name` LIKE '%Always-On%',CONVERT(REPLACE(`Served Impressions`,',',''), SIGNED INTEGER),0)) AS `DisplayAlwaysOnImpression`
,SUM(IF(`Campaign Name` LIKE '%Website%',CONVERT(REPLACE(`Served Impressions`,',',''), SIGNED INTEGER),0)) AS `DisplayWebsiteImpression`
,SUM(IF(`Campaign Name` IN ('Branding Campaign','New Product Launch'),CONVERT(REPLACE(`Served Impressions`,',',''), SIGNED INTEGER),0)) AS `DisplayBrandingImpression`
,SUM(IF(`Campaign Name` IN ('Holiday','July 4th'),CONVERT(REPLACE(`Served Impressions`,',',''), SIGNED INTEGER),0)) AS `DisplayHolidayImpression`
FROM mmm.mmm_dcmdisplay_2015
GROUP BY `Date`
)
;

CREATE TEMPORARY TABLE mmm.dcmtemp
(
SELECT 
`Date`
,SUM(CONVERT(REPLACE(`Served Impressions`,',',''), SIGNED INTEGER)) AS `DisplayImpression`
,SUM(IF(`Campaign Name` LIKE '%Always-On%',CONVERT(REPLACE(`Served Impressions`,',',''), SIGNED INTEGER),0)) AS `DisplayAlwaysOnImpression`
,SUM(IF(`Campaign Name` LIKE '%Website%',CONVERT(REPLACE(`Served Impressions`,',',''), SIGNED INTEGER),0)) AS `DisplayWebsiteImpression`
,SUM(IF(`Campaign Name` IN ('Branding Campaign','New Product Launch'),CONVERT(REPLACE(`Served Impressions`,',',''), SIGNED INTEGER),0)) AS `DisplayBrandingImpression`
,SUM(IF(`Campaign Name` IN ('Holiday','July 4th'),CONVERT(REPLACE(`Served Impressions`,',',''), SIGNED INTEGER),0)) AS `DisplayHolidayImpression`
FROM mmm.mmm_dcmdisplay_2017
GROUP BY `Date`
)
;

SELECT * FROM mmm.dcmtemp;

SELECT 
DISTINCT a.`Date`
FROM mmm.mmm_dcmdisplay_transformed a
INNER JOIN mmm.dcmtemp b
ON a.`Date` = b.`Date`
;

USE mmm;

DELETE a
FROM mmm.mmm_dcmdisplay_transformed a
INNER JOIN mmm.dcmtemp b
ON a.`Date` = b.`Date`
;

INSERT INTO mmm.mmm_dcmdisplay_transformed
SELECT * FROM mmm.dcmtemp
;

SELECT DISTINCT `Date` FROM mmm.mmm_dcmdisplay_transformed;

/*View*/

CREATE VIEW mmm.AnalyticalFile
AS
SELECT 
m.`Week`,
m.`Month`,
t1.Sales,
t2. `SalesEvent` AS `Sales Event`,
t3.`Unemployment Rate` AS`Unemployment Rate`,
t6.`DisplayImpression` AS `Display`
FROM (SELECT DISTINCT `Week`,`Month` FROM mmm.mmm_date_metadata) m
LEFT JOIN `mmm`.`mmm_sales_transformed` t1 ON m.`Week` = t1.`Week`
LEFT JOIN `mmm`.`mmm_event_transformed` t2 ON m.`Week` = t2.`Week`
LEFT JOIN `mmm`.`mmm_econ_transformed` t3 ON m.`Week` = t3.`Week`
LEFT JOIN `mmm`.`mmm_dcmdisplay_transformed` t6 ON m.`Week` = t6.`Date`
;


SELECT * FROM mmm.AnalyticalFile
















