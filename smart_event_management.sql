-- SMART EVENT MANAGEMENT SYSTEM

CREATE DATABASE IF NOT EXISTS smart_event_management;
USE smart_event_management;

-- 1. CREATE TABLES
CREATE TABLE Venues (
    venue_id INT PRIMARY KEY,
    venue_name VARCHAR(100) NOT NULL,
    location VARCHAR(100),
    capacity INT
);

CREATE TABLE Organizers (
    organizer_id INT PRIMARY KEY,
    organizer_name VARCHAR(100) NOT NULL,
    contact_email VARCHAR(100),
    phone_number VARCHAR(20)
);

CREATE TABLE Attendees (
    attendee_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    phone_number VARCHAR(20)
);

CREATE TABLE Events (
    event_id INT PRIMARY KEY,
    event_name VARCHAR(100) NOT NULL,
    event_date DATE NOT NULL,
    venue_id INT,
    organizer_id INT,
    ticket_price DECIMAL(10,2),
    total_seats INT,
    available_seats INT,

    FOREIGN KEY (venue_id) REFERENCES Venues(venue_id),
    FOREIGN KEY (organizer_id) REFERENCES Organizers(organizer_id)
);

CREATE TABLE Tickets (
    ticket_id INT PRIMARY KEY,
    event_id INT,
    attendee_id INT,
    booking_date DATE,
    status ENUM('Confirmed','Cancelled','Pending'),

    FOREIGN KEY (event_id) REFERENCES Events(event_id),
    FOREIGN KEY (attendee_id) REFERENCES Attendees(attendee_id),

    UNIQUE(event_id, attendee_id)
);

CREATE TABLE Payments (
    payment_id INT PRIMARY KEY,
    ticket_id INT,
    amount_paid DECIMAL(10,2),
    payment_status ENUM('Success','Failed','Pending'),
    payment_date DATETIME,

    FOREIGN KEY (ticket_id) REFERENCES Tickets(ticket_id)
);


-- 2. INSERT DATA

INSERT INTO Venues
VALUES
(1,'City Hall','Ahmedabad',1000),
(2,'Riverfront Ground','Ahmedabad',2000),
(3,'Convention Center','Surat',1500),
(4,'Town Hall','Vadodara',800),
(5,'Grand Arena','Rajkot',2500);

INSERT INTO Organizers
VALUES
(1,'Tech Events India','tech@gmail.com','9876543210'),
(2,'Music World','music@gmail.com','9876543211'),
(3,'Business Group','business@gmail.com','9876543212'),
(4,'Sports Events','sports@gmail.com','9876543213');

INSERT INTO Attendees
VALUES
(1,'Kush Kumar','kush@gmail.com','9000000001'),
(2,'Rahul Sharma','rahul@gmail.com','9000000002'),
(3,'Aman Patel',NULL,'9000000003'),
(4,'Priya Singh','priya@gmail.com','9000000004'),
(5,'Neha Verma','neha@gmail.com','9000000005');

INSERT INTO Events
VALUES
(1,'AI Conference','2026-12-10',1,1,1500,1000,300),
(2,'Music Festival','2026-12-15',2,2,2000,2000,150),
(3,'Business Summit','2026-12-20',3,3,2500,1500,700),
(4,'Cricket Tournament','2026-12-25',5,4,1000,2500,1200),
(5,'Coding Workshop','2026-11-30',4,1,800,800,400);

INSERT INTO Tickets
VALUES
(1,1,1,'2026-09-20','Confirmed'),
(2,1,2,'2026-09-21','Confirmed'),
(3,2,1,'2026-09-18','Confirmed'),
(4,2,3,'2026-09-19','Pending'),
(5,3,4,'2026-09-20','Confirmed'),
(6,4,5,'2026-09-21','Pending'),
(7,5,2,'2026-09-22','Confirmed');

INSERT INTO Payments
VALUES
(1,1,1500,'Success','2026-09-20 10:00:00'),
(2,2,1500,'Success','2026-09-21 11:00:00'),
(3,3,2000,'Success','2026-09-18 12:00:00'),
(4,4,2000,'Pending','2026-09-19 13:00:00'),
(5,5,2500,'Success','2026-09-20 14:00:00'),
(6,6,1000,'Pending','2026-09-21 15:00:00'),
(7,7,800,'Success','2026-09-22 16:00:00');


-- 3. CRUD OPERATIONS

-- ADD
INSERT INTO Events
VALUES
(6,'AI Workshop','2026-12-28',1,1,1200,500,500);

-- UPDATE
UPDATE Events
SET ticket_price = 1300
WHERE event_id = 6;

-- SEARCH
SELECT *
FROM Events
WHERE event_name LIKE '%AI%';

-- DELETE
DELETE FROM Events
WHERE event_id = 6;


-- 4. WHERE, HAVING, LIMIT

-- Upcoming events in Ahmedabad
SELECT e.event_name,e.event_date,v.location
FROM Events e
JOIN Venues v ON e.venue_id = v.venue_id
WHERE v.location = 'Ahmedabad'
AND e.event_date >= CURDATE();

-- TOP 5 revenue events
SELECT e.event_name,
       SUM(p.amount_paid) AS total_revenue
FROM Events e
JOIN Tickets t ON e.event_id = t.event_id
JOIN Payments p ON t.ticket_id = p.ticket_id
WHERE p.payment_status = 'Success'
GROUP BY e.event_id,e.event_name
ORDER BY total_revenue DESC
LIMIT 5;

-- Tickets booked in last 7 days
SELECT DISTINCT a.name,t.booking_date
FROM Attendees a
JOIN Tickets t ON a.attendee_id = t.attendee_id
WHERE t.booking_date >= CURDATE() - INTERVAL 7 DAY;

-- 5. AND, OR, NOT
-- December AND more than 50% seats available
SELECT *
FROM Events
WHERE MONTH(event_date) = 12
AND available_seats > total_seats * 0.50;

-- Booked OR pending payment
SELECT DISTINCT a.name
FROM Attendees a
LEFT JOIN Tickets t ON a.attendee_id = t.attendee_id
LEFT JOIN Payments p ON t.ticket_id = p.ticket_id
WHERE t.ticket_id IS NOT NULL
OR p.payment_status = 'Pending';

-- NOT fully booked
SELECT *
FROM Events
WHERE available_seats > 0;
-- 6. ORDER BY AND GROUP BY
-- Sort events by date
SELECT *
FROM Events
ORDER BY event_date ASC;

-- Count attendees per event
SELECT e.event_name,
       COUNT(t.attendee_id) AS total_attendees
FROM Events e
LEFT JOIN Tickets t ON e.event_id = t.event_id
GROUP BY e.event_id,e.event_name;

-- Total revenue per event
SELECT e.event_name,
       COALESCE(SUM(p.amount_paid),0) AS total_revenue
FROM Events e
LEFT JOIN Tickets t ON e.event_id = t.event_id
LEFT JOIN Payments p
ON t.ticket_id = p.ticket_id
AND p.payment_status = 'Success'
GROUP BY e.event_id,e.event_name;
-- 7. AGGREGATE FUNCTIONS
-- Total revenue
SELECT SUM(amount_paid) AS total_revenue
FROM Payments
WHERE payment_status = 'Success';

-- Highest ticket price
SELECT MAX(ticket_price) AS highest_ticket_price
FROM Events;

-- Lowest ticket price
SELECT MIN(ticket_price) AS lowest_ticket_price
FROM Events;

-- Average ticket price
SELECT AVG(ticket_price) AS average_ticket_price
FROM Events;

-- Number of events
SELECT COUNT(*) AS total_events
FROM Events;

-- Event with highest attendees
SELECT e.event_name,
       COUNT(t.attendee_id) AS total_attendees
FROM Events e
JOIN Tickets t ON e.event_id = t.event_id
GROUP BY e.event_id,e.event_name
ORDER BY total_attendees DESC
LIMIT 1;
-- 8. INNER JOIN
SELECT
    e.event_id,
    e.event_name,
    e.event_date,
    v.venue_name,
    v.location
FROM Events e
INNER JOIN Venues v
ON e.venue_id = v.venue_id;
-- 9. LEFT JOIN
-- Attendees who booked but did not complete payment
SELECT
    a.name,
    t.ticket_id,
    p.payment_status
FROM Attendees a
LEFT JOIN Tickets t
ON a.attendee_id = t.attendee_id
LEFT JOIN Payments p
ON t.ticket_id = p.ticket_id
WHERE t.ticket_id IS NOT NULL
AND (p.payment_status IS NULL
     OR p.payment_status <> 'Success');
-- 10. RIGHT JOIN
-- Events without attendees
SELECT
    e.event_id,
    e.event_name,
    t.attendee_id
FROM Tickets t
RIGHT JOIN Events e
ON t.event_id = e.event_id
WHERE t.attendee_id IS NULL;
-- 11. FULL OUTER JOIN
-- MySQL does not directly support FULL OUTER JOIN
SELECT
    a.attendee_id,
    a.name,
    t.ticket_id
FROM Attendees a
LEFT JOIN Tickets t
ON a.attendee_id = t.attendee_id

UNION

SELECT
    a.attendee_id,
    a.name,
    t.ticket_id
FROM Attendees a
RIGHT JOIN Tickets t
ON a.attendee_id = t.attendee_id;
-- 12. SUBQUERIES
-- Attendees who booked multiple events
SELECT
    a.name,
    COUNT(DISTINCT t.event_id) AS events_booked
FROM Attendees a
JOIN Tickets t
ON a.attendee_id = t.attendee_id
GROUP BY a.attendee_id,a.name
HAVING COUNT(DISTINCT t.event_id) > 1;
-- Organizers who managed more than 3 events
SELECT
    o.organizer_name,
    COUNT(e.event_id) AS total_events
FROM Organizers o
JOIN Events e
ON o.organizer_id = e.organizer_id
GROUP BY o.organizer_id,o.organizer_name
HAVING COUNT(e.event_id) > 3;
-- 13. DATE AND TIME FUNCTIONS
-- Extract month
SELECT
    event_name,
    event_date,
    MONTH(event_date) AS event_month
FROM Events;

-- Month name
SELECT
    event_name,
    MONTHNAME(event_date) AS month_name
FROM Events;

-- Days remaining
SELECT
    event_name,
    event_date,
    DATEDIFF(event_date,CURDATE()) AS days_remaining
FROM Events
WHERE event_date >= CURDATE();

-- Format payment date
SELECT
    payment_id,
    DATE_FORMAT(payment_date,'%Y-%m-%d %H:%i:%s')
    AS formatted_payment_date
FROM Payments;


-- 14. STRING FUNCTIONS

-- Uppercase organizer names
SELECT
    organizer_name,
    UPPER(organizer_name) AS uppercase_name
FROM Organizers;

-- Remove extra spaces
SELECT
    name,
    TRIM(name) AS cleaned_name
FROM Attendees;

-- Replace NULL email
SELECT
    name,
    COALESCE(email,'Not Provided') AS email
FROM Attendees;
-- 15. WINDOW FUNCTIONS
-- Rank events by revenue
SELECT
    e.event_name,
    SUM(p.amount_paid) AS total_revenue,
    RANK() OVER(
        ORDER BY SUM(p.amount_paid) DESC
    ) AS revenue_rank
FROM Events e
JOIN Tickets t
ON e.event_id = t.event_id
JOIN Payments p
ON t.ticket_id = p.ticket_id
WHERE p.payment_status = 'Success'
GROUP BY e.event_id,e.event_name;

-- Cumulative ticket sales
SELECT
    booking_date,
    COUNT(*) AS tickets_sold,
    SUM(COUNT(*)) OVER(
        ORDER BY booking_date
    ) AS cumulative_sales
FROM Tickets
GROUP BY booking_date
ORDER BY booking_date;
-- Running attendees per event
SELECT
    e.event_name,
    t.booking_date,
    COUNT(*) AS attendees,
    SUM(COUNT(*)) OVER(
        PARTITION BY e.event_id
        ORDER BY t.booking_date
    ) AS running_attendees
FROM Events e
JOIN Tickets t
ON e.event_id = t.event_id
GROUP BY e.event_id,e.event_name,t.booking_date;


-- 16. CASE EXPRESSIONS
-- Event demand
SELECT
    event_name,
    total_seats,
    available_seats,
    CASE
        WHEN available_seats < total_seats * 0.20
            THEN 'High Demand'
        WHEN available_seats BETWEEN
             total_seats * 0.20
             AND total_seats * 0.50
            THEN 'Moderate Demand'
        ELSE 'Low Demand'
    END AS demand_category
FROM Events;

-- Payment category
SELECT
    payment_id,
    payment_status,
    CASE
        WHEN payment_status = 'Success'
            THEN 'Successful'
        WHEN payment_status = 'Failed'
            THEN 'Failed'
        ELSE 'Pending'
    END AS payment_category
FROM Payments;
-- 17. EXTRA USEFUL QUERIES
-- Show all events
SELECT * FROM Events;

-- Show all venues
SELECT * FROM Venues;

-- Show all organizers
SELECT * FROM Organizers;

-- Show all attendees
SELECT * FROM Attendees;

-- Show all tickets
SELECT * FROM Tickets;

-- Show all payments
SELECT * FROM Payments;

-- Complete event details
SELECT
    e.event_name,
    e.event_date,
    v.venue_name,
    v.location,
    o.organizer_name,
    e.ticket_price,
    e.total_seats,
    e.available_seats
FROM Events e
JOIN Venues v
ON e.venue_id = v.venue_id
JOIN Organizers o
ON e.organizer_id = o.organizer_id;
