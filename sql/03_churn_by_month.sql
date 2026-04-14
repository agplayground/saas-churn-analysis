-- Ranking churn events to use only the latest one in the analysis
WITH last_churn AS (
  SELECT 
    account_id, 
    churn_date,
    reason_code,
    ROW_NUMBER() OVER (PARTITION BY account_id ORDER BY churn_date DESC) AS rn
  FROM `project-7cc9c569-446d-4cb3-a49.saas_subscription_funnel_retention_analysis.churn_events`
)
-- Combining permanently churned accounts data with their churn date for a monthly breakdown
SELECT 
    DATE_TRUNC(churn_date,MONTH) AS churn_month,
    COUNT(*)
FROM `project-7cc9c569-446d-4cb3-a49.saas_subscription_funnel_retention_analysis.accounts` a
LEFT JOIN last_churn lc ON 
  a.account_id = lc.account_id
  AND lc.rn = 1
WHERE 
    churn_flag = true
    AND churn_date IS NOT NULL
GROUP BY 1
