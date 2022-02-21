CREATE TABLE bookings.results (
	id int,
	response text NULL
);

INSERT INTO bookings.results
(id, response)
VALUES(3, '0');

---------1-------------
select max(count_pass) from (
select book_ref, count(distinct passenger_name) as count_pass from bookings.tickets group by book_ref) as a

select * from bookings.tickets group by book_ref
---------2-------------
select count(*) from (
select book_ref, count(*)  from bookings.tickets group by book_ref having count(*) >(
select avg(count_pass) from (
select count(*) as count_pass from bookings.tickets group by book_ref) a ) ) b

select count(*) from bookings.tickets

---------3-------------
select  pass from (
select book_ref, STRING_AGG ( passenger_name , ',' ORDER BY passenger_name) as pass  from bookings.tickets 
where book_ref in (select book_ref from bookings.tickets group by book_ref having count(*)=5)
group by book_ref order by STRING_AGG ( passenger_name , ',' ORDER BY passenger_name)  ) a 
group by  pass having count(*)>=2

select * from bookings.tickets where book_ref in (
select book_ref from bookings.tickets group by book_ref having  count(distinct passenger_name)>=5 )
order by book_ref, passenger_name 

---------4-------------
insert into bookings.results
select 4, book_ref || '|' || passenger_name || '|' ||contact_data from bookings.tickets where 
book_ref in (select book_ref from bookings.tickets group by book_ref having count(*)=3) 
order by book_ref, passenger_name, contact_data
---------5-------------
insert into bookings.results
select 5,max(count_all) from(
select t.book_ref , count(distinct tf.flight_id) as count_all from bookings.Tickets as t
join Ticket_flights as tf on t.ticket_no =tf.ticket_no 
group by t.book_ref ) a
-----------6--------------
insert into bookings.results
select 6, max(count_all) from(
select t.book_ref , passenger_id, count(distinct tf.flight_id) as count_all from bookings.Tickets as t
join Ticket_flights as tf on t.ticket_no =tf.ticket_no 
group by t.book_ref, passenger_id ) a

-----------7--------------
insert into bookings.results
select 7, max(count_all) from (
select passenger_id, count(*) as count_all from bookings.Tickets as t
join Ticket_flights as tf on t.ticket_no =tf.ticket_no group by t.passenger_id ) a

select * from bookings.tickets where passenger_name = 'ALEKSANDR IVANOV'
group by t.passenger_name

-----------8--------------
insert into bookings.results

select 8, t.passenger_id|| '|' || t.passenger_name|| '|' ||  t.contact_data|| '|' ||  sum(amount)::varchar 
from bookings.Tickets as t
join Ticket_flights as tf on t.ticket_no =tf.ticket_no 
group by t.passenger_id, t.passenger_name, t.contact_data
having sum(amount) = (
select min(count_all) from (
select  t.passenger_name , sum(amount) as count_all
from bookings.Tickets as t
join Ticket_flights as tf on t.ticket_no =tf.ticket_no 
group by  t.passenger_name 
) a)
order by t.passenger_id, t.passenger_name, t.contact_data

-----------9--------------
insert into bookings.results
select 9, t.passenger_id|| '|' || t.passenger_name|| '|' ||  t.contact_data|| '|' ||  count_all::varchar 
from bookings.Tickets as t
join(
select passenger_id , sum(actual_duration) as count_all, RANK () OVER ( 
		ORDER BY sum(actual_duration) desc ) as rank_ from bookings.Tickets as t
join Ticket_flights as tf on t.ticket_no =tf.ticket_no 
join bookings.flights_v as v on v.flight_id = tf.flight_id
group by passenger_id
having sum(actual_duration) is not null
) a on t.passenger_id = a.passenger_id and a.rank_=1
order by t.passenger_id, t.passenger_name, t.contact_data
-----------10--------------
insert into bookings.results
select 10, city from bookings.airports  group by city having count(*)>1 order by city
-----------11--------------
insert into bookings.results
select 11, departure_city from (
select departure_city, count(distinct arrival_city), RANK () OVER ( 
		ORDER BY count(distinct arrival_city) asc ) as rank_  from bookings.flights_v
		group by departure_city
		) a where a.rank_=1 order by departure_city

-----------12--------------
insert into bookings.results
select 12,d.departure_city || '|' || d.departure_city_2 from (
select  a.departure_city , b.departure_city as departure_city_2
from bookings.routes  as a
inner join bookings.routes  as b
on  a.departure_city<> b.departure_city
group by a.departure_city, b.departure_city
)  d
left join 
(
select  a.departure_city, a.arrival_city from bookings.routes  a group by a.departure_city, a.arrival_city 
) as c on d.departure_city = c.departure_city and d.departure_city_2 = c.arrival_city
where c.departure_city is null and c.arrival_city is null and d.departure_city < d.departure_city_2
order by d.departure_city, d.departure_city_2


-----------13--------------
insert into bookings.results
select distinct 13,  arrival_city from  bookings.routes where arrival_city not in 
(select arrival_city from bookings.routes where  departure_city = 'Москва') and arrival_city!='Москва'

-----------14--------------
insert into bookings.results
select 14, a.model from  bookings.flights f join bookings.aircrafts a on f.aircraft_code = a.aircraft_code
where f.status!='Cancelled'
group by a.model order by count(*) desc limit 1

-----------15--------------
insert into bookings.results
select 15, a.model from  bookings.flights f 
join bookings.aircrafts a on f.aircraft_code = a.aircraft_code
join bookings.Ticket_flights tf on tf.flight_id = f.flight_id 
join bookings.Tickets t on t.ticket_no =tf.ticket_no 
where f.status!='Cancelled'
group by a.model order by count(*) desc limit 1

-----------16--------------

insert into bookings.results
select 16,
  (DATE_PART('day', count_all) * 24 + 
               DATE_PART('hour', count_all)) * 60 +
               DATE_PART('minute',count_all)
               from 
               (
select (sum(scheduled_duration) - sum(actual_duration)) as count_all  from bookings.flights_v where status = 'Arrived') as a

-----------17--------------
insert into bookings.results
select distinct 17, 
 arrival_city  from bookings.flights_v where 
departure_city = 'Санкт-Петербург' and status = 'Arrived' and date_trunc('day', actual_departure) = '2016-09-13'::timestamp

-----------18--------------
insert into bookings.results
select distinct 18,
 flight_id || '|' ||  flight_no|| '|' || departure_city || '|' || arrival_city from bookings.flights_v where flight_id = (
select flight_id from bookings.ticket_flights group by flight_id order by sum(amount) desc limit 1)

-----------19--------------
insert into bookings.results
select distinct 19,
 date_trunc('day', actual_departure) from bookings.flights_v  
where status = 'Arrived' group by date_trunc('day', actual_departure) 
having count(*) =
(
select count(*)from bookings.flights_v  
where status = 'Arrived' group by date_trunc('day', actual_departure) order by count(*) limit 1)

-----------20--------------
insert into bookings.results
select  20, avg(count_all)  
from ( select count(*) as count_all, date_trunc('day', actual_departure)   from  bookings.flights_v where departure_city = 'Москва' and status = 'Arrived' 
and date_trunc('month', actual_departure) = '2016-09-01'::timestamp
group by date_trunc('day', actual_departure) ) as a

-----------21--------------
insert into bookings.results
select  21,
 departure_city from bookings.flights_v group by departure_city 
having avg(actual_duration)  > '03:00:00'::interval order by  avg(actual_duration) desc limit 5

select id from bookings.results group by id order by id