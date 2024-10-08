SELECT
mview_name,
last_refresh_date "START_TIME",
CASE
   WHEN fullrefreshtim <> 0 THEN
      LAST_REFRESH_DATE + fullrefreshtim/60/60/24
   WHEN increfreshtim <> 0 THEN
      LAST_REFRESH_DATE + increfreshtim/60/60/24
   ELSE
      LAST_REFRESH_DATE
END "END_TIME",
fullrefreshtim,
increfreshtim
FROM all_mview_analysis
WHERE owner='&user'
