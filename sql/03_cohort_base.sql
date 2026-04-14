-- Ranking churn events to be able to pull only the latest one, as the analysis is covering only users that churned and never came back
WITH last_churn AS (
  SELECT 
    account_id, 
    churn_date,
    ROW_NUMBER() OVER (PARTITION BY account_id ORDER BY churn_date DESC) AS rn
  FROM churn_events
)
-- Combining accounts and churn data to form the base for cohort analysis in Python (excluding accounts that are marked as churned but have no records in churn_events)
SELECT 
  a.account_id,
  DATE_TRUNC(a.signup_date,MONTH) AS cohort_month,
  ls.churn_date
FROM accounts a
LEFT JOIN last_churn ls ON 
  a.account_id = ls.account_id
  AND ls.rn = 1
WHERE 
  churn_flag = true
  AND churn_date IS NOT NULL
; 
