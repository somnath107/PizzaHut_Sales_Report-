# 1  Retrieve the total number of orders placed.

SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders; 

# 2 Calculate the total revenue generated from pizza sales.

with x as (select p.pizza_id , p.price , o.quantity , p.price * o.quantity as amount  from pizzas p 
join order_details o 
using(pizza_id) ) 

select round(sum(amount) ,2)  as total_revenue from x ;


# 3 Identify the highest-priced pizza. 

SELECT 
    t.name, p.price
FROM
    pizzas p
        JOIN
    pizza_types t USING (pizza_type_id)
WHERE
    p.price = (SELECT 
            MAX(price)
        FROM
            pizzas);


# 4 Identify the most common pizza size ordered. 

SELECT 
    size, SUM(quantity) AS count
FROM
    pizzas p
        JOIN
    order_details o USING (pizza_id)
GROUP BY size
ORDER BY count DESC
LIMIT 1;

# 5 List the top 5 most ordered pizza types along with their quantities. 

SELECT 
    p.name AS name, SUM(o.quantity) AS total_quantity
FROM
    pizza_types p
        JOIN
    pizzas a USING (pizza_type_id)
        JOIN
    order_details o USING (pizza_id)
GROUP BY name
ORDER BY total_quantity DESC
LIMIT 5; 

# 6  Join the necessary tables to find the total quantity of each pizza category ordered. 


SELECT 
    p.category, SUM(d.quantity) AS total_quantity
FROM
    pizza_types p
        JOIN
    pizzas s ON p.pizza_type_id = s.pizza_type_id
        JOIN
    order_details d ON d.pizza_id = s.pizza_id
GROUP BY p.category
ORDER BY total_quantity DESC;


# 7 Determine the distribution of orders by hour of the day. 



SELECT 
    HOUR(time) AS hour, COUNT(order_id)
FROM
    orders
GROUP BY HOUR(time)
ORDER BY COUNT(order_id) DESC; 


# 8 Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(pizza_type_id) AS types
FROM
    pizza_types
GROUP BY category;


# 9 Group the orders by date and calculate the average number of pizzas ordered per day. 

with x as (SELECT 
    DATE(o.date) AS date, sum(d.quantity) AS quantity
FROM
    order_details d
        JOIN
    orders o USING (order_id)
GROUP BY o.date
ORDER BY quantity DESC)

select round(avg(quantity) , 0) as avg_quantity from x ;


# 10 Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    p.name, 
    SUM(o.quantity * s.price) AS total_revenue
FROM pizza_types p
JOIN pizzas s 
    USING (pizza_type_id)
JOIN order_details o 
    USING (pizza_id)
GROUP BY p.name
ORDER BY total_revenue DESC 
limit 3 ;


# 11 Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    p.category,
    ROUND(100.0 * SUM(o.quantity * s.price) / (SELECT 
                    SUM(o2.quantity * s2.price)
                FROM
                    pizzas s2
                        JOIN
                    order_details o2 USING (pizza_id)),
            2) AS pct_contribution
FROM
    pizza_types p
        JOIN
    pizzas s USING (pizza_type_id)
        JOIN
    order_details o USING (pizza_id)
GROUP BY p.category
;


# 12  Analyze the cumulative revenue generated over time. 

with x as (select date(o.date) as date  , round(sum(p.price * d.quantity) , 2) as revenue
from orders o 
join order_details d 
using(order_id) 
join pizzas p 
using(pizza_id) 
group by date) 

select date, sum(revenue) over(order by date) as cummilative_revenue from x ;


# 13 Determine the top 3 most ordered pizza types based on revenue for each pizza category.


with x as (WITH pizza_revenue AS (
    SELECT 
        t.name,
        t.category,
        ROUND(SUM(p.price * o.quantity), 2) AS revenue
    FROM pizza_types t
    JOIN pizzas p 
        USING (pizza_type_id)
    JOIN order_details o 
        USING (pizza_id)
    GROUP BY t.name, t.category
)

SELECT 
    name,
    category,
    revenue,
    RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rankings
FROM pizza_revenue
ORDER BY category, rankings) 

select * from x 
where rankings <= 3 ;











