-- Aggregating churn_date as the analysis considers only those accounts that churned and never reactivated
WITH last_churn AS (
  SELECT 
    account_id, 
    MAX(churn_date) AS churn_date,
  FROM churn_events
  GROUP BY 1
)
-- Combining permanently churned accounts data with their churn date for a monthly breakdown
SELECT 
    DATE_TRUNC(churn_date,MONTH) AS churn_month,
    COUNT(*) AS churned_accounts
FROM accounts a
LEFT JOIN last_churn lc ON 
  a.account_id = lc.account_id
WHERE 
    churn_flag = true
    AND churn_date IS NOT NULL
GROUP BY 1
ORDER BY 1
;
