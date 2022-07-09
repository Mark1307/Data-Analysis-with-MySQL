/*
-- Q1
SELECT
	YEAR(website_sessions.created_at) as year,
	QUARTER(website_sessions.created_at) AS quarter,
	COUNT(website_sessions.website_session_id) as sessions,
    COUNT(orders.website_session_id) AS orders,
    COUNT(orders.website_session_id)*100/COUNT(website_sessions.website_session_id) AS session_to_order_conv
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2015-03-20'
GROUP BY 1,2
*/



/*
-- Q2
SELECT
	YEAR(website_sessions.created_at) as year,
	QUARTER(website_sessions.created_at) AS quarter,
	COUNT(website_sessions.website_session_id) as sessions,
    COUNT(orders.website_session_id) AS orders,
    COUNT(orders.website_session_id)*100/COUNT(website_sessions.website_session_id) AS session_to_order_conv,
    SUM(orders.price_usd) AS total_revenue,
    SUM(orders.price_usd)/COUNT(orders.website_session_id) AS revenue_per_order,
    SUM(orders.price_usd)/COUNT(website_sessions.website_session_id) AS revenue_per_session
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2015-03-20'
GROUP BY 1,2
*/



/*
-- Q3
SELECT
	YEAR(website_sessions.created_at) AS year,
    QUARTER(website_sessions.created_at) AS quarter,
	CASE WHEN utm_campaign IS NULL AND http_referer IS NULL THEN 'organic_search'
		 WHEN utm_campaign = 'nonbrand' AND http_referer = 'https://www.gsearch.com' THEN 'gsearch_nonbrand'
         WHEN utm_campaign = 'nonbrand' AND http_referer = 'https://www.bsearch.com' THEN 'bsearch_nonbrand'
         WHEN utm_campaign IS NULL AND http_referer IN ('https://www.gsearch.com','https://www.bsearch.com') THEN 'direct_search'
         WHEN utm_campaign IN ('brand','pilot','desktop_targeted') THEN 'overall_paid' ELSE NULL END AS channel_group,
	COUNT(website_sessions.website_session_id) AS sessions,
    COUNT(orders.website_session_id) AS orders
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2015-03-20'
GROUP BY 1,2,3
*/



/*
-- Q4
SELECT
	YEAR(website_sessions.created_at) AS year,
    QUARTER(website_sessions.created_at) AS quarter,
	CASE WHEN utm_campaign IS NULL AND http_referer IS NULL THEN 'organic_search'
		 WHEN utm_campaign = 'nonbrand' AND http_referer = 'https://www.gsearch.com' THEN 'gsearch_nonbrand'
         WHEN utm_campaign = 'nonbrand' AND http_referer = 'https://www.bsearch.com' THEN 'bsearch_nonbrand'
         WHEN utm_campaign IS NULL AND http_referer IN ('https://www.gsearch.com','https://www.bsearch.com') THEN 'direct_search'
         WHEN utm_campaign IN ('brand','pilot','desktop_targeted') THEN 'overall_paid' ELSE NULL END AS channel_group,
    COUNT(orders.website_session_id)*100/COUNT(website_sessions.website_session_id) AS session_to_order_conv
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2015-03-20'
GROUP BY 1,2,3
*/



/*
-- Q5
SELECT
	primary_product_id,
	MONTH(created_at) AS month,
    SUM(items_purchased) AS total_sales,
    SUM(price_usd) AS total_revenue,
    SUM(price_usd - cogs_usd) AS margin
FROM orders
WHERE created_at < '2015-03-20'
GROUP BY 1,2
ORDER BY 1,2
*/



/*
-- Q6
SELECT
	YEAR(created_at) AS year,
	MONTH(created_at) AS month,
	COUNT(CASE WHEN pageview_url = '/products' THEN website_session_id ELSE NULL END) AS products_page,
    COUNT(CASE WHEN pageview_url IN ('/the-original-mr-fuzzy','/the-forever-love-bear','/the-birthday-sugar-panda','/the-hudson-river-mini-bear') THEN website_session_id ELSE NULL END)*100/COUNT(CASE WHEN pageview_url = '/products' THEN website_session_id ELSE NULL END) AS product_nextpage_conv,
    COUNT(CASE WHEN pageview_url = '/thank-you-for-your-order' THEN website_session_id ELSE NULL END)*100/COUNT(CASE WHEN pageview_url = '/products' THEN website_session_id ELSE NULL END) AS product_orders_conv
FROM website_pageviews
WHERE created_at < '2015-03-20'
GROUP BY 1,2
ORDER BY 1,2
*/



/*
-- Q7
SELECT
	orders.primary_product_id,
    COUNT(CASE WHEN orders.primary_product_id IN (2,3,4) AND order_items.product_id = 1 AND order_items.is_primary_item = 0 THEN orders.order_id ELSE NULL END) AS '1',
    COUNT(CASE WHEN orders.primary_product_id IN (1,3,4) AND order_items.product_id = 2 AND order_items.is_primary_item = 0 THEN orders.order_id ELSE NULL END) AS '2',
    COUNT(CASE WHEN orders.primary_product_id IN (1,2,4) AND order_items.product_id = 3 AND order_items.is_primary_item = 0 THEN orders.order_id ELSE NULL END) AS '3',
    COUNT(CASE WHEN orders.primary_product_id IN (1,2,3) AND order_items.product_id = 4 AND order_items.is_primary_item = 0 THEN orders.order_id ELSE NULL END) AS '4'
FROM orders
	INNER JOIN order_items
		ON order_items.order_id = orders.order_id
WHERE orders.created_at BETWEEN '2014-12-05' AND '2015-03-20'
GROUP BY 1
ORDER BY 1
*/

