-- Identifying active and churned users
WITH funnel_base AS (
  SELECT 
    COUNT(a.account_id) AS signups,
    COUNT(CASE WHEN churn_flag=false THEN a.account_id END) AS active,
    COUNT(CASE WHEN churn_flag=true THEN a.account_id END) AS churned
  FROM accounts a
),
-- Ranking subscriptions to be able to pull only the latest one for churned MRR/ARR calculations, ignoring trials
last_sub AS (
  SELECT
    account_id,
    mrr_amount,
    ROW_NUMBER() OVER (PARTITION BY account_id ORDER BY start_date DESC) AS rn
  FROM subscriptions
  WHERE is_trial = false
),
-- Calculating churned revenue
churned_revenue AS (
  SELECT
    ROUND(SUM(ls.mrr_amount), 2) AS lost_mrr,
    ROUND(SUM(ls.mrr_amount) * 12, 2) AS lost_arr
  FROM accounts a
  JOIN last_sub ls ON 
    a.account_id = ls.account_id
  WHERE
    1=1
    AND a.churn_flag = true
    AND ls.rn = 1
)
-- Combining funnel and churn metrics to measure churn impact, in this data all signups have converted, hence churn_rate calculation is condsidering signups count
SELECT 
  signups,
  active,
  churned,
  churned / signups AS churn_rate,
  lost_mrr,
  lost_arr
FROM funnel_base
CROSS JOIN churned_revenue
