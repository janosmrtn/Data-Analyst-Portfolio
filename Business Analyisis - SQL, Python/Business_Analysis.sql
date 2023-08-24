-- Create tables and import data
CREATE TABLE purchase (
    my_timestamp TIMESTAMP,
    event_type TEXT,
    user_id TEXT,
    price INTEGER
);
COPY purchase FROM '/home/dataguy/dilan/purchase.csv' DELIMITER ';';

CREATE TABLE subscribe (
    my_timestamp TIMESTAMP,
    event_type TEXT,
    user_id TEXT
);
COPY subscribe FROM '/home/dataguy/dilan/subscribe.csv' DELIMITER ';';

CREATE TABLE first_reader (
    my_timestamp TIMESTAMP,
    event_type TEXT,
    country TEXT,
    user_id TEXT,
    source TEXT,
    topic TEXT
);
COPY first_reader FROM '/home/dataguy/dilan/first_reader.csv' DELIMITER ';';

CREATE TABLE return_reader (
    my_timestamp TIMESTAMP,
    event_type TEXT,
    country TEXT,
    user_id TEXT,
    topic TEXT
);
COPY return_reader FROM '/home/dataguy/dilan/return_reader.csv' DELIMITER ';';

-- Analyze user engagement by source, country, and topic
SELECT source, COUNT(DISTINCT user_id)
FROM first_reader
GROUP BY source;

SELECT country, COUNT(DISTINCT user_id)
FROM first_reader
GROUP BY country;

SELECT topic, COUNT(DISTINCT user_id)
FROM first_reader
GROUP BY topic;

-- Analyze user engagement over time
SELECT DATE(my_timestamp) AS date, COUNT(DISTINCT user_id)
FROM first_reader
GROUP BY DATE(my_timestamp);

-- Analyze first and return reader engagement by topic
SELECT first_reader.topic AS first_topic, COUNT(DISTINCT first_reader.user_id) AS first_read
FROM first_reader 
GROUP BY first_topic;

SELECT return_reader.topic AS return_topic, COUNT(DISTINCT return_reader.user_id) AS return_read
FROM return_reader 
GROUP BY return_topic;

-- Analyze combined first and return reader engagement by topic
SELECT first_reader.topic AS first_topic, COUNT(DISTINCT first_reader.user_id) AS first_read, COUNT(DISTINCT return_reader.user_id) AS return_read
FROM first_reader
LEFT JOIN return_reader ON first_reader.user_id = return_reader.user_id
GROUP BY first_topic;

SELECT return_reader.topic AS return_topic, COUNT(DISTINCT first_reader.user_id) AS first_read, COUNT(DISTINCT return_reader.user_id) AS return_read
FROM first_reader
LEFT JOIN return_reader ON first_reader.user_id = return_reader.user_id
GROUP BY return_topic;

-- Analyze engagement, subscriptions, and purchases over time
SELECT DATE(first_reader.my_timestamp), COUNT(DISTINCT first_reader.user_id) AS first_read, COUNT(DISTINCT return_reader.user_id) AS return_read, COUNT(DISTINCT subscribe.user_id) AS subscribe, COUNT(DISTINCT purchase.user_id) AS purchase
FROM first_reader
LEFT JOIN return_reader ON first_reader.user_id = return_reader.user_id
LEFT JOIN subscribe ON first_reader.user_id = subscribe.user_id
LEFT JOIN purchase ON first_reader.user_id = purchase.user_id
GROUP BY DATE(first_reader.my_timestamp);

-- Analyze engagement, subscriptions, and purchases by additional dimensions
SELECT DATE(first_reader.my_timestamp), first_reader.country, first_reader.topic, first_reader.source, COUNT(DISTINCT first_reader.user_id) AS first_read, COUNT(DISTINCT return_reader.user_id) AS return_read, COUNT(DISTINCT subscribe.user_id) AS subscribe, COUNT(DISTINCT purchase.user_id) AS purchase
FROM first_reader
LEFT JOIN return_reader ON first_reader.user_id = return_reader.user_id
LEFT JOIN subscribe ON first_reader.user_id = subscribe.user_id
LEFT JOIN purchase ON first_reader.user_id = purchase.user_id
GROUP BY DATE(first_reader.my_timestamp), first_reader.country, first_reader.topic, first_reader.source;

-- Analyze purchases by product type and date
SELECT DATE(my_timestamp) AS date, price,
    CASE WHEN price = 8 THEN 'booklet' ELSE 'video' END AS product_type,
    COUNT(user_id) AS orders
FROM purchase
GROUP BY DATE(my_timestamp), price
ORDER BY DATE(my_timestamp);

-- Analyze purchases by product type, date, and count
SELECT DATE(my_timestamp) AS date, price,
    CASE WHEN price = 8 THEN 'booklet' ELSE 'video' END AS product_type,
    COUNT(user_id) AS orders
FROM purchase
GROUP BY DATE(my_timestamp), price
ORDER BY DATE(my_timestamp);

-- Analyze purchases by source and product type
SELECT first_reader.source, COUNT(purchase.user_id) AS orders, purchase.price,
    CASE WHEN price = 8 THEN 'booklet' ELSE 'video' END AS product_type
FROM purchase
LEFT JOIN first_reader ON first_reader.user_id = purchase.user_id
GROUP BY first_reader.source, purchase.price;

-- Analyze purchases by country and product type
SELECT first_reader.country, COUNT(purchase.user_id) AS orders, purchase.price,
    CASE WHEN price = 8 THEN 'booklet' ELSE 'video' END AS product_type
FROM purchase
LEFT JOIN first_reader ON first_reader.user_id = purchase.user_id
GROUP BY first_reader.country, purchase.price;

-- Analyze purchases by date, country, and product type
SELECT DATE(purchase.my_timestamp), first_reader.country, COUNT(purchase.user_id) AS orders, purchase.price,
    CASE WHEN price = 8 THEN 'booklet' ELSE 'video' END AS product_type
FROM purchase
LEFT JOIN first_reader ON first_reader.user_id = purchase.user_id
GROUP BY DATE(purchase.my_timestamp), first_reader.country, purchase.price;

-- Calculate total sum of purchases
SELECT SUM(price) FROM purchase;
