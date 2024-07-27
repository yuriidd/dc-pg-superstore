--
--
-- === create table ship_modes

DROP TABLE IF EXISTS public.ship_modes;
CREATE TABLE public.ship_modes ( 
	ship_mode_id SERIAL NOT NULL,
	ship_mode VARCHAR(30) NOT NULL,
	last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  	PRIMARY KEY (ship_mode_id)
);

INSERT INTO public.ship_modes (ship_mode)
SELECT DISTINCT ship_mode
FROM raw.orders
;


--
--
-- === create table order_priority

DROP TABLE IF EXISTS public.order_priorities;
CREATE TABLE public.order_priorities ( 
	order_priority_id SERIAL NOT NULL,
	order_priority VARCHAR(30) NOT NULL,
	last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  	PRIMARY KEY (order_priority_id)
);

INSERT INTO public.order_priorities (order_priority)
SELECT DISTINCT ship_mode
FROM raw.orders
;


--
--
-- === create table products

DROP TABLE IF EXISTS public.products;
CREATE TABLE public.products (
	product_id SERIAL NOT NULL,
  	product_category VARCHAR(250) NOT NULL,
  	product_subcategory  VARCHAR(250) NOT NULL,
  	product_name VARCHAR(250) NOT NULL,
  	product_container VARCHAR(30) NOT NULL,
  	last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  	PRIMARY KEY (product_id)
);


-- find product_id duplicates and fix data
-- WITH 
-- cte AS (
-- 		SELECT DISTINCT product_name, product_subcategory
-- 		FROM stg.orders
-- 		),
-- cte_groupped AS (
-- 		SELECT product_name, COUNT(*) AS cnt
-- 		FROM cte
-- 		GROUP BY 1
-- 		HAVING COUNT(*) > 1
-- 		)
-- SELECT *
-- FROM cte_groupped
-- ;

-- find duplicate product_container
-- WITH
-- cte AS (
-- 	SELECT DISTINCT product_category, product_subcategory, product_name, product_container
-- 	FROM stg.orders
-- )
-- SELECT product_category, product_subcategory, product_name, count(*)
-- FROM cte
-- GROUP BY 1,2,3
-- HAVING count(*) > 1
-- ;

-- Canon PC940 Copier
UPDATE raw.orders
SET product_container = 'Large Box'
WHERE product_name = 'Canon PC940 Copier';

INSERT INTO public.products (product_category, product_subcategory, product_name, product_container)
SELECT DISTINCT product_category, product_subcategory, product_name, product_container
FROM raw.orders
;




--
--
-- === create table  customer

DROP TABLE IF EXISTS public.customers;
CREATE TABLE public.customers (
	customer_id SERIAL NOT NULL,
  	customer_name VARCHAR(250) NOT NULL,
	customer_segment VARCHAR(100) NOT NULL,
  	last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  	PRIMARY KEY (customer_id)
);

INSERT INTO public.customers (customer_name, customer_segment)
SELECT DISTINCT customer_name, customer_segment
FROM raw.orders
;




--
--
-- === create table     regions

DROP TABLE IF EXISTS public.regions;
CREATE TABLE public.regions ( 
	region_id SERIAL NOT NULL,
	region VARCHAR(30) NOT NULL,
	last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  	PRIMARY KEY (region_id)
);

INSERT INTO public.regions (region)
SELECT DISTINCT region
FROM raw.orders
;




--
--
-- === create table   locations

DROP TABLE IF EXISTS public.locations;
CREATE TABLE public.locations (
	location_id SERIAL NOT NULL,
	zip_code VARCHAR(10) NOT NULL,
	state VARCHAR(50) NOT NULL,
	city VARCHAR(50) NOT NULL,
	region_id INT NOT NULL,
	last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (location_id)
);

INSERT INTO public.locations (zip_code, state, city, region_id)
SELECT DISTINCT zip_code, state, city, r.region_id
FROM raw.orders AS o
LEFT JOIN public.regions AS r 	ON o.region = r.region
;




--
--
-- === create table   managers

DROP TABLE IF EXISTS public.managers;
CREATE TABLE public.managers (
	manager_id SERIAL NOT NULL,
	manager_name varchar(30) NOT NULL,
	region_id INT NOT NULL,
	last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (manager_id)
);


INSERT INTO public.managers (manager_name, region_id)
SELECT DISTINCT manager, r.region_id
FROM raw.managers AS u
LEFT JOIN public.regions AS r 	ON u.region = r.region
;


--
--
-- === create table    fact_orders

DROP TABLE IF EXISTS public.fact_orders;
CREATE TABLE public.fact_orders (
	row_id SERIAL,
	order_id INT ,
	order_date DATE,
	ship_date DATE,
	ship_mode VARCHAR(30),     
	order_priority_id INT,
	customer_id INT NOT NULL,
	location_id INT NOT NULL,
	manager_id INT NOT NULL,
	product_id INT NOT NULL,
	unit_price NUMERIC NOT NULL CHECK (unit_price > 0), 
	quantity INT NOT NULL CHECK (quantity > 0),
	sales NUMERIC NOT NULL,
	profit NUMERIC,
	discount NUMERIC,
	shipping_cost NUMERIC,
	product_base_margin NUMERIC,
	PRIMARY KEY (row_id)
);

-- CHECK (salary > 0)


INSERT INTO public.fact_orders (
	order_id
	, order_date
	, ship_date
	, ship_mode
	, order_priority_id
	, customer_id
	, location_id
	, manager_id
	, product_id
	, unit_price
	, quantity
	, sales
	, profit
	, discount
	, shipping_cost
	, product_base_margin
	)
SELECT
	order_id
	, order_date
	, ship_date
	, ship_mode
	, op.order_priority_id
	, c.customer_id
	, l.location_id
	, m.manager_id
	, p.product_id
	, unit_price
	, quantity
	, sales
	, profit
	, discount
	, shipping_cost
	, product_base_margin
FROM raw.orders AS o
LEFT JOIN public.order_priorities AS op	
		ON o.order_priority = op.order_priority
LEFT JOIN public.customers AS c 	
		ON o.customer_name = c.customer_name 
		AND o.customer_segment = c.customer_segment
LEFT JOIN public.locations AS l 
		ON o.zip_code = l.zip_code
		AND o.state = l.state
		AND o.city = l.city
LEFT JOIN public.managers AS m 
		ON l.region_id = m.region_id
LEFT JOIN products AS p
		ON o.product_category = p.product_category
		AND o.product_subcategory = p.product_subcategory
		AND o.product_name = p.product_name
;


-- end










































