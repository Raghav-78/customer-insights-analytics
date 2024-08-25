
create database dinner;
use dinner;
show databases;
create table sales(customer_id VARCHAR(1),order_date DATE,product_id integer);
describe sales;
insert into sales (customer_id,order_date,product_id) values
('A', '2021-01-01', 1),
	('A', '2021-01-01', 2),
	('A', '2021-01-07', 2),
	('A', '2021-01-10', 3),
	('A', '2021-01-11', 3),
	('A', '2021-01-11', 3),
	('B', '2021-01-01', 2),
	('B', '2021-01-02', 2),
	('B', '2021-01-04', 1),
	('B', '2021-01-11', 1),
	('B', '2021-01-16', 3),
	('B', '2021-02-01', 3),
	('C', '2021-01-01', 3),
	('C', '2021-01-01', 3),
	('C', '2021-01-07', 3);
    
    create table menu(product_id int,product_name varchar(5),price integer);
    INSERT INTO menu
	(product_id, product_name, price)
VALUES
	(1, 'sushi', 10),
    (2, 'curry', 15),
    (3, 'ramen', 12);
    
    create table members(customer_id varchar(1),join_date DATE);
    
    insert into members(customer_id,join_date) values ('A','2021-01-07'),
    ('B','2021-01-09');
    
    
    
    
    
    /*1. What is the total amount each customer spent at the restaurant?*/
    select  sales.customer_id,sum(menu.price) as total_amount
    from sales join menu 
    on sales.product_id=menu.product_id
    group by sales.customer_id;
    
    
    
    
    
    
    
    -- 2. How many days has each customer visited the restaurant?-- 
    select  customer_id, count(distinct order_date) as days
    from sales 
    group by customer_id;  
    
    
    
    
    
    
    -- 3. What was the first item from the menu purchased by each customer?-- 
    WITH  temp as (select sales.customer_id,min(sales.order_date) as datee from
    sales 
    group by sales.customer_id ) 
    
    select temp.customer_id,menu.product_name
    from temp join sales on temp.customer_id=sales.customer_id
    and temp.datee=sales.order_date -- IMP in 6,7 also--
     join menu on sales.product_id=menu.product_id;
    
   
   
    
    
    -- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?--
    
    select menu.product_name ,count(*) as most_count
    from sales
    join menu on 
    sales.product_id=menu.product_id
    group by menu.product_name
    order by most_count desc;
   -- limit 1;
    
    
    
    
    
    
    -- 5. Which item was the most popular for each customer?-- 
       
      WITH TEMP AS (select sales.customer_id,sales.product_id,count(*) as cc,
      row_number() over(partition by sales.customer_id order by count(*) desc) as rankk
      from sales
      group by sales.customer_id,product_id)
      
      select temp.customer_id,menu.product_name,temp.cc,temp.rankk
      from temp join menu 
      on temp.product_id=menu.product_id
      order by temp.customer_id,temp.rankk;
     -- where rankk=1;
     
     
     /*IN ABOVE SUSHI LIKES 3 PRODUCT EQUALY BUT IN OUTPUT WE ONLY GET 1 OUTPUT ,BEACUSE OF ROW NUMBER ASSIGN UNIQUELY */
     /*TO OVER COME THAT PROBLEM WE CAN USE RANK OR DENSE_RANK*/
     
     
      WITH TEMP AS (select sales.customer_id,sales.product_id,count(*) as cc,
      RANK() over(partition by sales.customer_id order by count(*) desc) as rankk
      from sales
      group by sales.customer_id,product_id)
      
      select temp.customer_id,menu.product_name,temp.cc,temp.rankk
      from temp join menu 
      on temp.product_id=menu.product_id
      order by temp.customer_id,temp.rankk;
      -- where rank=1;
     
       
       
       
       
       
       
	
       -- 6. Which item was purchased first by the customer after they became a member?-- 
       
        WITH temp as (select sales.customer_id,min(sales.order_date) as datee
          from sales
        join  members
        on sales.customer_id=members.customer_id
      where sales.order_date>=members.join_date
        group by sales.customer_id)
        
        select temp.customer_id,menu.product_name
        from temp join 
        sales on temp.customer_id=sales.customer_id and temp.datee=sales.order_date     -- IMP--
        join menu on sales.product_id=menu.product_id;
        
        
     
        
-- select *,count(*) over() from sales;
-- select *,count(*) from sales;
       
       
       
       
       
       
       
       
       -- 7. Which item was purchased just before the customer became a member?-- 
         WITH temp as (select sales.customer_id,max(sales.order_date) as datee
          from sales
        join  members
        on sales.customer_id=members.customer_id
      where sales.order_date<members.join_date
        group by sales.customer_id)
        
        select temp.customer_id,menu.product_name
        from temp join 
        sales on temp.customer_id=sales.customer_id and temp.datee=sales.order_date     -- IMP in3,6,7--
        join menu on sales.product_id=menu.product_id;
       
       
       
       
       
       
       -- 8. What is the total items and amount spent for each member before they became a member?-- 
       
       select sales.customer_id,count(sales.product_id),sum(menu.price)
       from sales 
       join menu on sales.product_id=menu.product_id
       join members on sales.customer_id=members.customer_id
       where sales.order_date<members.join_date
       group by sales.customer_id;
       
       
       
       
       
       
       -- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?-- 
       
       select sales.customer_id ,sum(
       CASE 
           when menu.product_id=1 then price*20
           else
           price*10  END) as points
		from sales 
        join menu on sales.product_id=menu.product_id
        group by sales.customer_id;
        
        
        
        
        
        
        
        /* 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - 
how many points do customer A and B have at the end of January?*/

     select sales.customer_id,sum(
     case
         when sales.order_date between members.join_date and DATE_ADD(members.join_date, INTERVAL 7 DAY)
         then price*20
         when menu.product_name='sushi' then price*20
         else
         price*10
         end ) as points
  
   from members right join sales
   on sales.customer_id=members.customer_id
   join menu
   on menu.product_id=sales.product_id
   where sales.order_date<='2021-01-31'
   group by sales.customer_id;
         
     



        
	   -- Recreate the table output using the available data--  
       SELECT s.customer_id, s.order_date, m.product_name, m.price,
      CASE WHEN s.order_date >= mb.join_date THEN 'Y'
         ELSE 'N' END AS member
        FROM sales s
         JOIN menu m ON s.product_id = m.product_id
       LEFT JOIN members mb ON s.customer_id = mb.customer_id;
     
     
    
    
    
    
       -- 12. Rank all the things:--
       
                    with  customers_data AS (
	                SELECT s.customer_id, s.order_date, m.product_name, m.price,
	                 CASE
	                     	WHEN s.order_date < mb.join_date THEN 'N'
	                     	WHEN s.order_date >= mb.join_date THEN 'Y'
		                    ELSE 'N' END AS member
					FROM sales s
					LEFT JOIN members mb ON s.customer_id = mb.customer_id
					JOIN menu m ON s.product_id = m.product_id)
  
	SELECT *,
         CASE WHEN member = 'N' THEN NULL
         ELSE RANK() OVER(PARTITION BY customer_id, member ORDER BY order_date)
          END AS ranking
   FROM customers_data
   ORDER BY customer_id, order_date;

