SELECT * FROM claims;
SELECT * FROM policy_sales;


#Calculate the total premium collected during the year 2024.
SELECT SUM(premium) AS total_premium_2024
FROM policy_sales
WHERE YEAR(policy_purchase_date) = 2024;


#Calculate the total claim cost for each year (2025 and 2026) with a monthly breakdown.
SELECT SUM(claim_amount) AS total_claim_cost_2025_and_2026
FROM claims
WHERE YEAR(claim_date) = 2025 and 2026;


#Calculate the claim cost to premium ratio for each policy tenure (1, 2, 3, and 4 years).
SELECT 
    policy_tenure,
    SUM(claim_amount) AS total_claim_cost,
    SUM(premium) AS total_premium,
    ROUND(SUM(claim_amount) / SUM(premium), 4) AS claim_to_premium_ratio
FROM claims
WHERE policy_tenure IN (1,2,3,4)
GROUP BY policy_tenure
ORDER BY policy_tenure;


#Calculate the claim cost to premium ratio by the month in which the policy was sold (January–December 2024).
SELECT 
    MONTH(policy_purchase_date) AS sale_month,
    SUM(claim_amount) AS total_claim_cost,
    SUM(premium) AS total_premium,
    ROUND(SUM(claim_amount) / SUM(premium), 4) AS claim_to_premium_ratio
FROM claims
WHERE policy_purchase_date >= '2024-01-01'
  AND policy_purchase_date < '2025-01-01'
GROUP BY MONTH(policy_purchase_date)
ORDER BY sale_month;


/*If every vehicle that has not yet made a claim eventually files exactly 
one claim during the remaining policy tenure, estimate the total potential claim liability.*/
-- Step 1: Find all policies that have not yet filed a claim and set it as variable.
SET @unclaimed_policy_count = (
	SELECT COUNT(*)
	FROM policy_sales
	LEFT JOIN claims
		ON policy_sales.cust_id = claims.cust_id
		AND policy_sales.vehicle_id  = claims.vehicle_id
		AND policy_sales.policy_start_date = claims.policy_start_date
		AND policy_sales.policy_end_date  = claims.policy_end_date
	WHERE claims.claim_type IS NULL OR 0
);
-- Step 2: Find the avg claim amount that will be the potential claim liablity per unclaimed policy and set it as variable.
SET @avg_claim_cost = (
	SELECT ROUND(AVG(claim_amount), 2)
	FROM Claims
);
-- Step 3: Estimate the total potential claim liability for all unclaimed policies using the calculated average claim cost and unclaimed policies.
SELECT
	@unclaimed_policy_count AS unclaimed_policies,
    @avg_claim_cost AS avg_claim,
    ROUND((@unclaimed_policy_count * @avg_claim_cost), 2) AS estimated_liability;


/* Assume daily premium = Total Premium ÷ Total Policy Tenure Days. Based on this: 
• Calculate the premium already earned by the company up to February 28, 2026. 
• Estimate the premium expected to be earned monthly for the remaining policy period 
(assume 46 months remaining).*/
-- Step 1: Set Variable and calculating daily premium.
SET @daily_premium = (
SELECT SUM(premium) FROM policy_sales
)/
( 
 SELECT SUM(DATEDIFF(policy_end_date, policy_start_date)) FROM policy_sales);
 SELECT @daily_premium;
-- Step 2: Set Variable and calculating earned premium till 28 feb 2026.
SET @earned_premium = (
	@daily_premium *
	(SELECT SUM(DATEDIFF
				("2026-02-28", policy_start_date))
    FROM policy_sales)
);
SELECT @earned_premium;
-- Step 3: Calculating expected monthly earning assuming 46 months remaining.
SELECT ROUND(
	((
    (SELECT SUM(premium) FROM policy_sales) - @earned_premium)/46), 2) as expected_monthly_premium;