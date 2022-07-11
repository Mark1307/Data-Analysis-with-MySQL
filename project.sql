-- Skills used : Joins, Sub Queries, Temp Tables, Aggregate Functions and Date Functions



-- Setting Schema
USE mavenfuzzyfactory;



-- overview of our database tables
SELECT * FROM order_item_refunds;
SELECT * FROM order_items;
SELECT * FROM orders;
SELECT * FROM website_pageviews;
SELECT * FROM website_sessions;
SELECT * FROM products;



-- Sessions to order conversion percentage 
SELECT
	MONTH(website_pageviews.created_at) AS MONTH,
    COUNT(DISTINCT website_pageviews.website_session_id) AS no_of_sessions,
	COUNT(CASE WHEN website_pageviews.pageview_url = '/thank-you-for-your-order' THEN website_pageviews.website_session_id ELSE NULL END) AS no_of_orders,
    COUNT(CASE WHEN website_pageviews.pageview_url = '/thank-you-for-your-order' THEN website_pageviews.website_session_id ELSE NULL END)*100/COUNT(DISTINCT website_pageviews.website_session_id) AS session_to_orders_percent
FROM website_pageviews
WHERE website_pageviews.created_at < '2012-11-27'
GROUP BY 1;



-- Quarterly trend analysis for sessions and orders
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
GROUP BY 1,2;



-- gsearch campaign source driven us the more traffic for our website
-- Monthly trend analysis for gsearch nonbrand and brand campaigns
SELECT
	MONTH(website_pageviews.created_at) AS MONTH,
    website_sessions.utm_source AS utm_source,
    website_sessions.utm_campaign,
    COUNT(DISTINCT website_pageviews.website_session_id) AS no_of_sessions,
	COUNT(CASE WHEN website_pageviews.pageview_url = '/thank-you-for-your-order' THEN website_pageviews.website_session_id ELSE NULL END) AS no_of_orders
FROM website_pageviews
	LEFT JOIN website_sessions
		ON website_pageviews.website_session_id = website_sessions.website_session_id
WHERE website_pageviews.created_at < '2012-11-27' AND website_sessions.utm_source = 'gsearch'
GROUP BY 1, 2, 3;



-- There are two different device types : mobile and desktop
-- Monthly sessions and orders based on device type
SELECT
	MONTH(website_pageviews.created_at) AS MONTH,
    website_sessions.utm_campaign,
    website_sessions.device_type,
    COUNT(DISTINCT website_pageviews.website_session_id) AS no_of_sessions,
	COUNT(CASE WHEN website_pageviews.pageview_url = '/thank-you-for-your-order' THEN website_pageviews.website_session_id ELSE NULL END) AS no_of_orders,
    COUNT(CASE WHEN website_pageviews.pageview_url = '/thank-you-for-your-order' THEN website_pageviews.website_session_id ELSE NULL END)*100/COUNT(DISTINCT website_pageviews.website_session_id) AS session_to_orders_percent
FROM website_pageviews
	LEFT JOIN website_sessions
		ON website_pageviews.website_session_id = website_sessions.website_session_id
WHERE website_pageviews.created_at < '2012-11-27' AND website_sessions.utm_source = 'gsearch' AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY 1, 2, 3;



-- Monthly trend analysis for sessioins and orders of different channels (utm_sources)
SELECT
	MONTH(website_pageviews.created_at) AS MONTH,
    CASE WHEN website_sessions.utm_source IN ('bsearch', 'gsearch') THEN website_sessions.utm_source ELSE 'direct/organic search' END AS channels,
    website_sessions.device_type,
    COUNT(DISTINCT website_pageviews.website_session_id) AS no_of_sessions,
	COUNT(CASE WHEN website_pageviews.pageview_url = '/thank-you-for-your-order' THEN website_pageviews.website_session_id ELSE NULL END) AS no_of_orders
FROM website_pageviews
	LEFT JOIN website_sessions
		ON website_pageviews.website_session_id = website_sessions.website_session_id
WHERE website_pageviews.created_at < '2012-11-27'
GROUP BY 1, 2, 3;



-- Comparision of revenue generated between newly created homepage (lander-1) and old homepage
SELECT
	website_pageviews.pageview_url,
    COUNT(website_pageviews.website_session_id) AS total_sessions,
    COUNT(orders.order_id) AS total_orders,
    COUNT(orders.order_id)*100/COUNT(website_pageviews.website_session_id) AS session_to_order_percent,
    SUM(orders.price_usd) AS total_revenue
FROM website_pageviews
	LEFT JOIN orders
		ON website_pageviews.website_session_id = orders.website_session_id
WHERE website_pageviews.created_at BETWEEN '2012-06-19' AND '2012-07-28' AND website_pageviews.pageview_url IN ('/home','/lander-1')
GROUP BY 1;



-- full conversion funnel from both homepages (/home, /lander-1) to order page
SELECT 
	temp.page_name,
    COUNT(temp.website_session_id) AS sessions,
	COUNT(CASE WHEN website_pageviews.pageview_url = '/products' THEN website_pageviews.website_session_id ELSE NULL END) AS products_page,
    COUNT(CASE WHEN website_pageviews.pageview_url = '/the-original-mr-fuzzy' THEN website_pageviews.website_session_id ELSE NULL END) AS item_page,
    COUNT(CASE WHEN website_pageviews.pageview_url = '/cart' THEN website_pageviews.website_session_id ELSE NULL END) AS cart_page,
    COUNT(CASE WHEN website_pageviews.pageview_url = '/shipping' THEN website_pageviews.website_session_id ELSE NULL END) AS shipping_page,
    COUNT(CASE WHEN website_pageviews.pageview_url = '/billing' THEN website_pageviews.website_session_id ELSE NULL END) AS billing_page,
    COUNT(DISTINCT temp.order_id) AS ordered
FROM(
SELECT
	website_pageviews.pageview_url AS page_name,
    website_pageviews.website_session_id,
    orders.order_id
FROM website_pageviews
	LEFT JOIN orders
		ON website_pageviews.website_session_id = orders.website_session_id
WHERE website_pageviews.created_at BETWEEN '2012-06-19' AND '2012-07-28' AND website_pageviews.pageview_url IN ('/home','/lander-1')
) AS temp
	INNER JOIN website_pageviews
		ON website_pageviews.website_session_id = temp.website_session_id
GROUP BY 1;



-- Comparision of newly created billing page (billing-2) page with the old one (billing) based on revenue
SELECT
	website_pageviews.pageview_url AS billing_page,
    COUNT(website_pageviews.website_session_id) AS billing_sessions,
    SUM(orders.price_usd) AS total_revenue,
    SUM(orders.price_usd)/COUNT(website_pageviews.website_session_id) AS revenue_per_billing_session
FROM website_pageviews
	LEFT JOIN orders
		ON website_pageviews.website_session_id = orders.website_session_id
WHERE website_pageviews.created_at BETWEEN '2012-09-10' AND '2012-11-10' AND website_pageviews.pageview_url IN ('/billing','/billing-2')
GROUP BY 1;



-- Quarterly trend analysis for revenue per session and revenue per order
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
GROUP BY 1,2;



-- Quarterly trend analysis for different type of channel group's sessions and orders
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
GROUP BY 1,2,3;



-- Month wise revenue analysis
SELECT
	MONTH(created_at) AS month,
    SUM(items_purchased) AS total_sales,
    SUM(price_usd) AS total_revenue,
    SUM(price_usd - cogs_usd) AS margin
FROM orders
WHERE created_at < '2015-03-20'
GROUP BY 1
ORDER BY 1;



-- Monthly trend analysis for products page to any of the nextpage and orders page conversion percents
SELECT
	YEAR(created_at) AS year,
	MONTH(created_at) AS month,
	COUNT(CASE WHEN pageview_url = '/products' THEN website_session_id ELSE NULL END) AS products_page,
    COUNT(CASE WHEN pageview_url IN ('/the-original-mr-fuzzy','/the-forever-love-bear','/the-birthday-sugar-panda','/the-hudson-river-mini-bear') THEN website_session_id ELSE NULL END)*100/COUNT(CASE WHEN pageview_url = '/products' THEN website_session_id ELSE NULL END) AS product_nextpage_conv,
    COUNT(CASE WHEN pageview_url = '/thank-you-for-your-order' THEN website_session_id ELSE NULL END)*100/COUNT(CASE WHEN pageview_url = '/products' THEN website_session_id ELSE NULL END) AS product_orders_conv
FROM website_pageviews
WHERE created_at < '2015-03-20'
GROUP BY 1,2
ORDER BY 1,2;



-- Cross sell analysis for each product with any other product
SELECT
	orders.primary_product_id,
    COUNT(CASE WHEN orders.primary_product_id IN (2,3,4) AND order_items.product_id = 1 AND order_items.is_primary_item = 0 THEN orders.order_id ELSE NULL END) AS 'cross_sell_1',
    COUNT(CASE WHEN orders.primary_product_id IN (1,3,4) AND order_items.product_id = 2 AND order_items.is_primary_item = 0 THEN orders.order_id ELSE NULL END) AS 'cross_sell_2',
    COUNT(CASE WHEN orders.primary_product_id IN (1,2,4) AND order_items.product_id = 3 AND order_items.is_primary_item = 0 THEN orders.order_id ELSE NULL END) AS 'cross_sell_3',
    COUNT(CASE WHEN orders.primary_product_id IN (1,2,3) AND order_items.product_id = 4 AND order_items.is_primary_item = 0 THEN orders.order_id ELSE NULL END) AS 'cross_sell_4'
FROM orders
	INNER JOIN order_items
		ON order_items.order_id = orders.order_id
WHERE orders.created_at BETWEEN '2014-12-05' AND '2015-03-20'
GROUP BY 1
ORDER BY 1;




