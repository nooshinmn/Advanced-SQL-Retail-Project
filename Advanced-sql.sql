drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'09-22-2017'),
(3,'04-21-2017');

drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'09-02-2014'),
(2,'01-15-2015'),
(3,'04-11-2014');

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'04-19-2017',2),
(3,'12-18-2019',1),
(2,'07-20-2020',3),
(1,'10-23-2019',2),
(1,'03-19-2018',3),
(3,'12-20-2016',2),
(1,'11-09-2016',1),
(1,'05-20-2016',3),
(2,'09-24-2017',1),
(1,'03-11-2017',2),
(1,'03-11-2016',1),
(3,'11-10-2016',1),
(3,'12-07-2017',2),
(3,'12-15-2016',2),
(2,'11-08-2017',2),
(2,'09-10-2018',3);


drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

1 what is the total amount each customer spent on zomato?

select s.userid, sum(p.price) total_spent from sales s inner join product p on s.product_id = p.product_id
group by s.userid

2 How many days has ech customer visited zomato?

select userid, COUNT(distinct created_date) distinct_days from sales group by userid;

3 what was the first product purchased by each customer?

select * from
(select *, RANK() over(partition by userid order by created_date) rnk from sales) a where rnk=1;

4 what is the most purchased item on the menu and how many times was it purchased by all customers?

select userid, count(product_id) cnt from sales where product_id=
(select top 1 product_id from sales group by product_id order by count(product_id) desc)
group by userid;

5 which item was the most popular for each customer?

select * from
(select *, RANK() over (partition by userid order by cnt desc) rnk from
(select userid, product_id, COUNT(product_id) cnt from sales group by userid, product_id) a) b
where rnk=1

6 which item was purchased first by the customer after they become a member?

select * from
(select c.*, RANK() over(partition by userid order by created_date) rnk from
(select a.userid, a.created_date, a.product_id, b.gold_signup_date from sales a inner join
goldusers_signup b on a.userid = b.userid and created_date >= gold_signup_date) c) d where rnk=1;

7 which item was purchased just before the customer become a member?

select * from
(select c.*, RANK() over(partition by userid order by created_date desc) rnk from
(select a.userid, a.created_date, a.product_id, b.gold_signup_date from sales a inner join
goldusers_signup b on a.userid = b.userid and created_date >= gold_signup_date) c) d where rnk=1;

8 what is total orders and amount spent for each customer before they become a member?

SELECT d.userid, count(d.created_date) as total_orders, sum(d.price) total_price from
(select c.*, p.price from
(select a.userid, a.created_date, a.product_id, b.gold_signup_date from sales a inner join
goldusers_signup b on a.userid = b.userid and created_date <= gold_signup_date)c inner join product p
on p.product_id= c.product_id) d group by d.userid

9 If buying each product generates points and each product has different purchasing
points for eg p1 5$=1, p2 10$=5 and p3 5$=1 point,
calculate points collected by each customer and for which product most points have been given till now?

select f.userid, sum(f.total_points) as total_points from
(select e.*, total/points as total_points from
(select d.*, case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end as points from
(select c.userid, c.product_id, sum(price) total from
(select a.*, b.price  from sales a inner join product b on a.product_id= b.product_id) c 
group by userid, product_id) d)e) f group by userid 

select g.*, rank() over(order by total_points desc) rnk from
(select f.product_id, sum(f.total_points) as total_points from
(select e.*, total/points as total_points from
(select d.*, case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end as points from
(select c.userid, c.product_id, sum(price) total from
(select a.*, b.price  from sales a inner join product b on a.product_id= b.product_id) c 
group by userid, product_id) d)e) f group by product_id)g


