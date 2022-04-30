/*** Exploring The Members Data ***/

-- 1)Show only the top 5 rows from the trading.members table

SELECT * 
FROM trading.members
LIMIT 5;

-- 2) Sort all the rows in the table by first_name in alphabetical order and show the top 3 rows
SELECT * 
FROM trading.members
ORDER BY first_name
LIMIT 3;

-- 3) Which records from trading.members are from the United States region?
SELECT * 
FROM trading.members
WHERE region = 'United States';

-- 4) Select only the member_id and first_name columns for members who are not from Australia
SELECT member_id, first_name 
FROM trading.members
WHERE region != 'Australia';

-- 5) Return the unique region values from the trading.members table and sort the output by reverse alphabetical order
SELECT DISTINCT region
FROM trading.members 
ORDER BY region DESC;

-- 6) How many mentors are there from Australia or the United States?
SELECT COUNT(*)
FROM trading.members
WHERE region IN ('United States', 'Australia');

-- 7) How many mentors are NOT there from Australia or the United States?
SELECT COUNT(*)
FROM trading.members
WHERE region NOT IN ('United States', 'Australia');

-- 8) How many mentors are there per region? Sort the output by regions with the most mentors to the least
SELECT region, COUNT(*) AS num_of_mentors
FROM trading.members
GROUP BY region 
ORDER BY COUNT(*) DESC;

-- 9) How many US mentors and non US mentors are there?
SELECT 
	CASE WHEN region = 'United States' THEN 'US'
		 ELSE 'Non US' END AS mentor_region,
	COUNT(*)
FROM trading.members
GROUP BY mentor_region;

-- 10) How many mentors have a first name starting with a letter before 'E'?
SELECT *
FROM trading.members
WHERE first_name like '_E%';

/*** Daily Prices ***/
-- 1) How many total records do we have in the trading.prices table?
SELECT COUNT(*)
FROM trading.prices;

-- 2) How many records are there per ticker value?
SELECT ticker, COUNT(*)
FROM trading.prices
GROUP BY ticker;

-- 3) What is the minimum and maximum market_date values?
SELECT MAX(market_date), MIN(market_date)
FROM trading.prices;

-- 4) Are there differences in the minimum and maximum market_date values for each ticker?
SELECT ticker, MAX(market_date), MIN(market_date)
FROM trading.prices
GROUP BY ticker;

-- 5) What is the average of the price column for Bitcoin records during the year 2020?
SELECT ROUND(AVG(price),2) AS average_price
FROM trading.prices 
WHERE ticker = 'BTC' and 
market_date BETWEEN '2020-01-01' AND '2020-12-31';

-- 6) What is the monthly average of the price column for Ethereum in 2020? Sort the output in chronological order and also round the average price value to 2 decimal places
SELECT EXTRACT(MONTH FROM market_date) AS months, ROUND(AVG(price),2) AS monthly_average
FROM trading.prices
WHERE ticker = 'ETH' and 
EXTRACT(YEAR FROM market_date) = 2020
GROUP BY months
ORDER BY months;

-- 7) Are there any duplicate market_date values for any ticker value in our table?
SELECT ticker,
  COUNT(market_date) AS total_count,
  COUNT(DISTINCT market_date) AS unique_count
FROM trading.prices
GROUP BY ticker;

-- 8) How many days from the trading.prices table exist where the high price of Bitcoin is over $30,000?
SELECT COUNT(DISTINCT market_date) 
FROM trading.prices
WHERE ticker = 'BTC' AND
high > '30000';

-- 9) How many "breakout" days were there in 2020 where the price column is greater than the open column for each ticker?
SELECT ticker, COUNT(DISTINCT market_date) 
FROM trading.prices
WHERE price > open 
AND EXTRACT(YEAR FROM market_date) = 2020
GROUP BY ticker;

-- 10) How many "non_breakout" days were there in 2020 where the price column is less than the open column for each ticker?
SELECT ticker, COUNT(DISTINCT market_date) 
FROM trading.prices
WHERE price < open 
AND EXTRACT(YEAR FROM market_date) = 2020
GROUP BY ticker;

-- 11) What percentage of days in 2020 were breakout days vs non-breakout days? Round the percentages to 2 decimal places?
SELECT ticker, 
ROUND(SUM( CASE WHEN price > open THEN 1 ELSE 0 END)/COUNT(*),2) AS breakout_percentage,
ROUND(SUM( CASE WHEN price < open THEN 1 ELSE 0 END)/COUNT(*),2) AS non_breakout_percentage
FROM trading.prices
WHERE EXTRACT(YEAR FROM market_date) = 2020
GROUP BY ticker;

/** Transactions Table **/
-- 1) How many records are there in the trading.transactions table?
SELECT COUNT(*) 
FROM trading.transactions;

-- 2) How many unique transactions are there?
SELECT COUNT(DISTINCT txn_id) 
FROM trading.transactions;

/** 3) For each year, calculate the following buy and sell metrics for Bitcoin 
-total transaction count
-total quantity
-average quantity per transaction
Also round the quantity columns to 2 decimal places **/

SELECT EXTRACT(YEAR FROM txn_time) AS txn_year, txn_type,
 COUNT(txn_id) AS total_count, ROUND(SUM(quantity),2) AS total_quantity, ROUND(AVG(quantity),2) AS average_quantity
FROM trading.transactions
WHERE ticker = 'BTC'
GROUP BY txn_year, txn_type;

-- 4) What was the monthly total quantity purchased and sold for Ethereum in 2020?
SELECT EXTRACT(MONTH FROM txn_time) AS txn_month,txn_type, SUM(quantity)
FROM trading.transactions
WHERE ticker = 'ETH' AND
EXTRACT(YEAR FROM txn_time) = 2020
GROUP BY txn_month, txn_type;

/** 5) Summarise all buy and sell transactions for each member_id by generating 1 row for each member with the following additional columns:
Bitcoin buy quantity
Bitcoin sell quantity
Ethereum buy quantity
Ethereum sell quantity **/
SELECT member_id,
SUM(CASE WHEN ticker = 'BTC' AND txn_type = 'BUY' THEN quantity ELSE 0 END) AS Bitcoin_buy_quantity,
SUM(CASE WHEN ticker = 'BTC' AND txn_type = 'SELL' THEN quantity ELSE 0 END) AS Bitcoin_sell_quantity,
SUM(CASE WHEN ticker = 'ETH' AND txn_type = 'BUY' THEN quantity ELSE 0 END) AS Ethereum_buy_quantity,
SUM(CASE WHEN ticker = 'ETH' AND txn_type = 'SELL' THEN quantity ELSE 0 END) AS Ethereum_sell_quantity
FROM trading.transactions
GROUP BY member_id;

-- 6) What was the final quantity holding of Bitcoin for each member? Sort the output from the highest BTC holding to lowest
SELECT member_id, SUM(CASE WHEN txn_type = 'BUY' THEN quantity ELSE 0 END) - SUM(CASE WHEN txn_type = 'SELL' THEN quantity ELSE 0 END)
FROM trading.transactions
WHERE ticker = 'BTC'
GROUP BY member_id;

-- 7) Which members have sold less than 500 Bitcoin? Sort the output from the most BTC sold to least
SELECT member_id,SUM(quantity) AS btc_sold_quantity
FROM trading.transactions
WHERE ticker = 'BTC'
  AND txn_type = 'SELL'
GROUP BY member_id
HAVING SUM(quantity) < 500
ORDER BY btc_sold_quantity DESC;

-- 8) Which member_id has the highest buy to sell ratio by quantity?
SELECT member_id, SUM(CASE WHEN txn_type = 'BUY' THEN quantity ELSE 0 END)/ SUM(CASE WHEN txn_type = 'SELL' THEN quantity ELSE 0 END) AS ratio
FROM trading.transactions
GROUP BY member_id
ORDER BY ratio DESC;

-- 9) For each member_id - which month had the highest total Ethereum quantity sold`?
WITH CTE AS (SELECT member_id,EXTRACT(MONTH FROM txn_time) AS txn_month, SUM(quantity) AS qty_sold, 
			RANK() OVER (PARTITION BY member_id ORDER BY SUM(quantity) DESC) AS month_rank 
            FROM trading.transactions 
			WHERE ticker = 'ETH' AND txn_type = 'SELL'
            GROUP BY member_id, txn_month)
SELECT member_id, txn_month ,qty_sold
FROM CTE
WHERE month_Rank = 1;

/** Realistic Analytics **/

-- 1) What is the earliest and latest date of transactions for all members?
SELECT member_id, MAX(txn_time) AS latest_txn , Min(txn_time) AS earliest_txn
FROM trading.transactions
GROUP BY member_id;

-- 2) What is the range of market_date values available in the prices data?
SELECT MIN(market_date), MAX(market_date)
FROM trading.prices;

-- 3) Which top 3 mentors have the most Bitcoin quantity as of the 29th of August?
SELECT m.first_name, 
SUM(CASE WHEN t.txn_type = 'BUY' THEN t.quantity
	 ELSE -t.quantity END) AS total_qty
FROM trading.members m
JOIN trading.transactions t
ON m.member_id = t.member_id
WHERE t.ticker = 'BTC'
GROUP BY m.first_name
ORDER BY total_qty DESC
LIMIT 3;

-- 4) What is total value of all Ethereum portfolios for each region at the end date of our analysis? Order the output by descending portfolio value
WITH cte_latest_price AS (
  SELECT ticker,price
  FROM trading.prices
  WHERE ticker = 'ETH'
  AND market_date = '2021-08-29')
SELECT m.region,
  SUM(CASE
      WHEN t.txn_type = 'BUY'  THEN t.quantity
      WHEN t.txn_type = 'SELL' THEN -t.quantity
    END) * c.price AS ethereum_value
FROM trading.transactions t
INNER JOIN cte_latest_price c
  ON t.ticker = c.ticker
INNER JOIN trading.members m
  ON t.member_id = m.member_id
WHERE t.ticker = 'ETH'
GROUP BY m.region, c.price
ORDER BY ethereum_value DESC;

-- 5) What is the average value of each Ethereum portfolio in each region? Sort this output in descending order
WITH cte_latest_price AS (
  SELECT ticker,price
  FROM trading.prices
  WHERE ticker = 'ETH'
  AND market_date = '2021-08-29')
SELECT m.region,
  AVG(CASE
      WHEN t.txn_type = 'BUY'  THEN t.quantity
      WHEN t.txn_type = 'SELL' THEN -t.quantity
    END) * c.price AS ethereum_value
FROM trading.transactions t
INNER JOIN cte_latest_price c
  ON t.ticker = c.ticker
INNER JOIN trading.members m
  ON t.member_id = m.member_id
WHERE t.ticker = 'ETH'
GROUP BY m.region, c.price
ORDER BY ethereum_value DESC;

/** What is the total portfolio value for each mentor at the end of 2020?
What is the total portfolio value for each region at the end of 2019?
What percentage of regional portfolio values does each mentor contribute at the end of 2018?
Does this region contribution percentage change when we look across both Bitcoin and Ethereum portfolios independently at the end of 2017? **/

-- CREATING BASE TABLE TO REFER TO ANSWER ABOVE QUESTIONS

DROP TABLE IF EXISTS temp_portfolio_base;
CREATE TEMPORARY TABLE temp_portfolio_base AS
WITH CTE AS (
SELECT m.first_name, m.region, t.txn_time, t.Ticker,
	CASE WHEN t.txn_type = 'BUY'  THEN t.quantity
	 WHEN t.txn_type = 'SELL' THEN -t.quantity END AS adjusted_qty
FROM trading.members m
JOIN trading.transactions t
ON m.member_id = t.member_id
WHERE t.txn_time <= '2020-12-31')
SELECT first_name, region, EXTRACT(YEAR FROM txn_time) AS year_end, ticker, SUM(adjusted_qty) AS total_Qty
FROM CTE 
GROUP BY first_name, region,year_end, ticker
ORDER BY first_name;

SELECT * FROM temp_portfolio_base;

SELECT year_end,ticker,total_qty,
  SUM(total_qty) OVER (PARTITION BY first_name, ticker ORDER BY year_end ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS cumulative_quantity
FROM temp_portfolio_base
WHERE first_name = 'Abe'
ORDER BY ticker, year_end;

ALTER TABLE temp_portfolio_base
DROP cumulative_quantity ;

ALTER TABLE temp_portfolio_base
ADD cumulative_quantity FLOAT;

UPDATE temp_portfolio_base 
SET cumulative_quantity =
(SELECT SUM(total_Qty) OVER (PARTITION BY first_name, TICKER ORDER BY year_end ));

DROP TABLE IF EXISTS temp_cumulative_portfolio_base;
CREATE TEMPORARY TABLE temp_cumulative_portfolio_base AS
SELECT first_name,region,year_end,ticker,total_qty,
  SUM(total_qty) OVER (
    PARTITION BY first_name, ticker
    ORDER BY year_end
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS cumulative_quantity
FROM temp_portfolio_base;

SELECT * FROM temp_cumulative_portfolio_base;

-- 1) What is the total portfolio value for each mentor at the end of 2020?
SELECT t.first_name, SUM(t.cumulative_quantity * p.price) AS portfolio_value
FROM temp_cumulative_portfolio_base t
JOIN trading.prices p 
ON t.ticker = p.ticker
AND t.year_end = Extract(YEAR FROM p.market_date) 
WHERE year_end = '2020'
GROUP BY t.first_name
ORDER BY portfolio_value DESC;

-- 2) What is the total portfolio value for each region at the end of 2019?
SELECT t.region, SUM(t.cumulative_quantity * p.price) AS portfolio_value
FROM temp_cumulative_portfolio_base t
JOIN trading.prices p 
ON t.ticker = p.ticker
AND t.year_end = Extract(YEAR FROM p.market_date) 
WHERE year_end = '2019'
GROUP BY t.region;

-- 3) What percentage of regional portfolio values does each mentor contribute at the end of 2018?
WITH CTE_mentor AS (SELECT t.region, t.first_name, SUM(t.cumulative_quantity * p.price) AS portfolio_value
					FROM temp_cumulative_portfolio_base t
					JOIN trading.prices p 
					ON t.ticker = p.ticker
					AND t.year_end = Extract(YEAR FROM p.market_date) 
					WHERE year_end = '2018'
					GROUP BY t.region,t.first_name),
CTE_region AS ( SELECT region, first_name, portfolio_value, 
				SUM(portfolio_value) OVER (PARTITION BY region) AS region_total
				FROM CTE_mentor) 
SELECT region, first_name , ROUND(100 * portfolio_value / region_total, 2) AS percentage
FROM CTE_region;

-- 4) Does this region contribution percentage change when we look across both Bitcoin and Ethereum portfolios independently at the end of 2017?
WITH CTE_mentor AS (SELECT t.region, t.first_name,t.ticker, SUM(t.cumulative_quantity * p.price) AS portfolio_value
					FROM temp_cumulative_portfolio_base t
					JOIN trading.prices p 
					ON t.ticker = p.ticker
					AND t.year_end = Extract(YEAR FROM p.market_date) 
					WHERE year_end = '2017'
					GROUP BY t.region,t.first_name,t.ticker),
CTE_region AS ( SELECT region, first_name,ticker, portfolio_value, 
				SUM(portfolio_value) OVER (PARTITION BY region, ticker) AS region_total
				FROM CTE_mentor) 
SELECT region, first_name ,ticker, ROUND(100 * portfolio_value / region_total, 2) AS percentage
FROM CTE_region
ORDER BY region, first_name ,ticker;

-- 5) Calculate the ranks for each mentor in the US and Australia for each year and ticker
SELECT year_end,region,first_name,ticker,
  RANK() OVER (PARTITION BY region, year_end ORDER BY cumulative_quantity DESC) AS ranks
FROM temp_cumulative_portfolio_base
WHERE region IN ('United States', 'Australia')
ORDER BY year_end, region, ranks;

-- pivot table for readibility
WITH CTE AS (SELECT year_end,region,first_name,ticker,
  RANK() OVER (PARTITION BY region, year_end ORDER BY cumulative_quantity DESC) AS ranks
FROM temp_cumulative_portfolio_base
WHERE region IN ('United States', 'Australia'))
SELECT region, first_name , 
  MAX(CASE WHEN ticker = 'BTC' AND year_end = '2017-12-31' THEN ranks ELSE NULL END) AS "BTC 2017",
  MAX(CASE WHEN ticker = 'BTC' AND year_end = '2018-12-31' THEN ranks ELSE NULL END) AS "BTC 2018",
  MAX(CASE WHEN ticker = 'BTC' AND year_end = '2019-12-31' THEN ranks ELSE NULL END) AS "BTC 2019",
  MAX(CASE WHEN ticker = 'BTC' AND year_end = '2020-12-31' THEN ranks ELSE NULL END) AS "BTC 2020",
  MAX(CASE WHEN ticker = 'ETH' AND year_end = '2017-12-31' THEN ranks ELSE NULL END) AS "ETH 2017",
  MAX(CASE WHEN ticker = 'ETH' AND year_end = '2018-12-31' THEN ranks ELSE NULL END) AS "ETH 2018",
  MAX(CASE WHEN ticker = 'ETH' AND year_end = '2019-12-31' THEN ranks ELSE NULL END) AS "ETH 2019",
  MAX(CASE WHEN ticker = 'ETH' AND year_end = '2020-12-31' THEN ranks ELSE NULL END) AS "ETH 2020"
FROM cte
GROUP BY region, first_name
ORDER BY region, "BTC 2017";


-- Creating mentor performnace table

WITH cte_portfolio AS (SELECT m.first_name, m.region, t.ticker,t.txn_type,
    COUNT(*) AS transaction_count,
    SUM(t.quantity) AS total_quantity,
    SUM(t.quantity * p.price) AS gross_values,
    SUM(t.quantity * p.price * t.percentage_fee / 100) AS fees 
  FROM trading.members m
  JOIN trading.transactions t
  ON m.member_id = t.member_id
  INNER JOIN trading.prices p
    ON t.ticker = p.ticker
    AND DATE(txn_time) = p.market_date
  GROUP BY m.first_name, m.region, t.ticker,t.txn_type
),
cte_summary AS (SELECT first_name, region, ticker,
    SUM(CASE WHEN txn_type = 'BUY' THEN total_quantity
             WHEN txn_type = 'SELL' THEN -total_quantity END) AS final_quantity,
    SUM(CASE WHEN txn_type = 'BUY' THEN gross_values ELSE 0 END) AS initial_investment,
    SUM(CASE WHEN txn_type = 'SELL' THEN gross_values ELSE 0 END) AS sales_revenue,
    SUM(CASE WHEN txn_type = 'BUY' THEN fees ELSE 0 END) AS purchase_fees,
    SUM(CASE WHEN txn_type = 'SELL' THEN fees ELSE 0 END) AS sales_fees,
    SUM(CASE WHEN txn_type = 'BUY' THEN total_quantity ELSE 0 END) AS purchase_quantity,
    SUM(CASE WHEN txn_type = 'SELL' THEN total_quantity ELSE 0 END) AS sales_quantity,
    SUM(CASE WHEN txn_type = 'BUY' THEN transaction_count ELSE 0 END) AS purchase_transactions,
    SUM(CASE WHEN txn_type = 'SELL' THEN transaction_count ELSE 0 END) AS sales_transactions
  FROM cte_portfolio
  GROUP BY first_name, region,ticker
),
cte_metrics AS (SELECT summary.first_name, summary.region,summary.ticker,
    summary.final_quantity * final.price AS actual_final_value,
    summary.purchase_quantity * final.price AS theoretical_final_value,
    summary.sales_revenue,
    summary.purchase_fees,
    summary.sales_fees,
    summary.initial_investment,
    summary.purchase_quantity,
    summary.sales_quantity,
    summary.purchase_transactions,
    summary.sales_transactions,
    summary.initial_investment / purchase_quantity AS dollar_cost_average,
    summary.sales_revenue / sales_quantity AS average_selling_price
  FROM cte_summary AS summary
  INNER JOIN trading.prices AS final
    ON summary.ticker = final.ticker
  WHERE final.market_date = '2021-08-29'
)
SELECT first_name, region,ticker,actual_final_value AS final_portfolio_value,
  ( actual_final_value + sales_revenue - purchase_fees - sales_fees ) / initial_investment AS actual_profitability,
  ( theoretical_final_value - purchase_fees ) / initial_investment AS theoretical_profitability,
  dollar_cost_average,
  average_selling_price,
  sales_revenue,
  purchase_fees,
  sales_fees,
  initial_investment,
  purchase_quantity,
  sales_quantity,
  purchase_transactions,
  sales_transactions
FROM cte_metrics;
