/* 0] What is the total amount each customer spent on zomato ?*/ 
select s.userid, s.product_id, p.price
from sale s
inner join product p
on s.product_id=p.product_id;

/* 1] How many days has each customer visited zomato ?*/
select s.userid, sum(p.price) as total_amount_spent
from sale s
inner join product p
on s.product_id=p.product_id
group by s.userid;

/*2] What was the first product purcheased by each customer ?*/
select userid, count(distinct created_date) as distinct_days from sale group by userid;

/*3] What */
select * from 
(select *, rank() over(partition by userid order by created_date) as rnk from sale) 
a where rnk =1;

/*4] What is the most purchased item on the menu and how many times was it purchased by all customers ? */
select userid, product_id, count(product_id) as most_purchased_item 
from sale where product_id = 
(select product_id from sale group by product_id order by count(product_id) desc limit 1)
group by userid;

/*5] Which item was the most popular for each customer ? */
select * from
(select *, rank() over(partition by userid order by most_purchased_item desc) rnk from 
(select userid, product_id, count(product_id) as most_purchased_item from sale group by userid, product_id)s)p
where rnk =1;

/*6] Which item was purchased first by the customer after they become a member ? */
select * from
(select c.* , rank() over (partition by userid order by created_date) rnk from
(select s.userid, s.created_date, s.product_id, g.gold_signup_date from sale s inner join 
goldusers_signup g on s.userid=g.userid and created_date>= gold_signup_date) c)d 
where rnk=1;

/*7] Which item was purchased first by the customer before they become a member ? */
select * from
(select c.* , rank() over (partition by userid order by created_date desc) rnk from
(select s.userid, s.created_date, s.product_id, g.gold_signup_date from sale s inner join 
goldusers_signup g on s.userid=g.userid and created_date<= gold_signup_date) c)d 
where rnk=1;

/*8] What is the total orders and amount spent for each member before they become a member ? */
select userid, count(created_date) as order_purchased, sum(price) as total_amount_spent from
(select c.*,p.price from
(select s.userid, s.created_date, s.product_id, g.gold_signup_date from sale s inner join
goldusers_signup g on s.userid=g.userid and created_date<= gold_signup_date)c inner join product p on c.product_id=p.product_id)e
group by userid;

/*9] If buying each product generates points for eg 5rs-2 zomato point and each product has different purchasing points for pl 5rs-1 zomato point for p2 10rs-5zomato point p3 5rs-1 zomato point 2rs-1zomato point
calculate points collected by each customers and for which product most points have been given till now ?*/

select userid, sum(total_points)*2.5 total_money_earned from
(select e.*, amt/points total_points from
(select d.*, case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end as points from
(select c.userid, c.product_id,sum(price) amt from
(select a.*,b.price from sale a inner join product b on a.product_id=b.product_id) c
group by userid, product_id)d)e)f 
group by userid;


select * from
(select rank() over (order by total_point_earned desc) rnk from
(select product_id,sum(total_points) as total_point_earned from
(select e.*,amt/points total_points from
(select d.*, case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end as points from
(select c.userid,c.product_id, sum(price) as amt from
(select a.*, b.price from sale a inner join product b on a.product_id=b.product_id) c
group by userid, product_id)d)e)f group by product_id)f)g 
where rnk=1;

/* 10] 10 In the first one year after a customer joins the gold program (including their join date) irrespective of what the customer has purchased they earn 5 zomato points for every 10 rs spent who earned more 1 or 3 and what was their points earnings in thier first yr?
1 zp=2rs
0.5 zp=1rs ?*/
/*select c.*, d.price*0.5 total_points_earned from
(select a.userid, a.created_date,a.product_id,b.gold_signup_date from sale a inner join
goldusers_signup b on a.userid=b.userid and created_date>=gold_signup_date and created_date<=DATEADD(year, 1,gold_signup_date))c
inner join product d on c.product_id=d.product_id;*/

SELECT c.*, d.price*0.5 AS total_points_earned 
FROM (
    SELECT a.userid, a.created_date, a.product_id, b.gold_signup_date 
    FROM sale a 
    INNER JOIN goldusers_signup b 
    ON a.userid=b.userid AND created_date>=gold_signup_date AND created_date<=DATE_ADD(gold_signup_date, INTERVAL 1 YEAR)
) c
INNER JOIN product d 
ON c.product_id=d.product_id;

/*11] 11 rnk all the transaction of the customers? */
select *, rank() over (partition by userid order by created_date) rnk from sale;

/* 12] rank all the transactions for each member whenever they are a zomato gold member for every non gold member transction mark as na ?*/
select c.*, rank() over(partition by userid order by created_date desc) rnk from 
(select a.userid, a.created_date,a.product_id,b.gold_signup_date 
from sale a left join goldusers_signup b on a.userid-b.userid and created_date>=gold_signup_date)c;