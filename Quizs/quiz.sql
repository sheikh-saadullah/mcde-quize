-- ==== ASSIGNMENT TASKS ====
/* Task 1 — Build the Sales Detail Dataset (6 marks)
Management needs a detailed sales dataset for analysis. Return one row per order item containing:
order_id and order_date
customer full name
store name
staff full name
product name
category name
brand name
quantity, list_price, discount
calculated net_line_revenue

Include only completed orders (order_status = 4). Sort the result from newest order to oldest.
 */

 SELECT
    o.order_id,
    o.order_date,
    o.order_status,
    c.first_name+' '+c.last_name  AS customer_full_name,
    s.store_name,
    st.first_name+' '+st.last_name AS staff_full_name,
    p.product_name,
    cat.category_name,
    b.brand_name,
    oi.quantity,
    oi.list_price,
    oi.discount,
    (oi.quantity * oi.list_price * (1 - oi.discount)) AS net_line_revenue
FROM sales.order_items AS oi
INNER JOIN sales.orders AS o ON oi.order_id = o.order_id
INNER JOIN sales.customers AS c ON o.customer_id = c.customer_id
INNER JOIN sales.stores AS s ON o.store_id = s.store_id
INNER JOIN sales.staffs AS st ON o.staff_id = st.staff_id
INNER JOIN production.products AS p ON oi.product_id = p.product_id
INNER JOIN production.categories AS cat ON p.category_id = cat.category_id
INNER JOIN production.brands AS b ON p.brand_id = b.brand_id
WHERE o.order_status = 4
ORDER BY o.order_date DESC;

/* Task 2 — Store Performance Summary (5 marks)
Create a store-level performance report for completed orders showing:
store name
number of distinct orders
total units sold
total net revenue
average order value

Return one row per store and order the stores from highest to lowest total net revenue.
 */

 SELECT
    s.store_name,
    COUNT(DISTINCT o.order_id) AS num_orders,
    SUM(oi.quantity) AS total_units_sold,
    SUM(oi.list_price) AS total_net_revenue,
    AVG(oi.item_id)AS avg_order_value
FROM sales.stores AS s
INNER JOIN sales.orders AS o ON s.store_id = o.store_id
INNER JOIN sales.order_items AS oi ON o.order_id = oi.order_id
WHERE o.order_status = 4
GROUP BY s.store_name
ORDER BY total_net_revenue DESC;   

/* Task 3 — High-Value Customers (5 marks)
Management wants to identify high-value customers. 
Return customers whose total completed-order spending is greater than the 
average total spending of customers who have completed orders.

Show customer_id, customer name, completed order count, and total spending. 
Order the result by total spending descending.
 */
 WITH customer_spending AS (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        COUNT(DISTINCT o.order_id)  AS completed_order_count,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_spending
    FROM sales.customers  c
    JOIN sales.orders     o  ON c.customer_id = o.customer_id
    JOIN sales.order_items oi ON o.order_id   = oi.order_id
    WHERE o.order_status = 4          -- 4 = Completed
    GROUP BY c.customer_id, c.first_name, c.last_name
)
SELECT
    customer_id,
    first_name + ' ' + last_name AS customer_name,
    completed_order_count,
    total_spending
FROM customer_spending
WHERE total_spending > (SELECT AVG(total_spending) FROM customer_spending)
ORDER BY total_spending DESC;   

/* Task 4 — Inventory Risk Report (5 marks)
Operations wants to identify inventory risk. Return products where the stock quantity is below 5 in at least one store.

Show product name, store name, current quantity, category name, and brand name. 
Products with zero stock should appear first, followed by the lowest remaining quantities.
*/

SELECT
    p.product_name,
    s.store_name,
    st.quantity,
    c.category_name,
    b.brand_name
FROM production.stocks      st
JOIN production.products    p  ON st.product_id = p.product_id
JOIN production.categories  c  ON p.category_id = c.category_id
JOIN production.brands      b  ON p.brand_id    = b.brand_id
JOIN sales.stores           s  ON st.store_id   = s.store_id
WHERE st.quantity < 5
ORDER BY st.quantity ASC, p.product_name;    
