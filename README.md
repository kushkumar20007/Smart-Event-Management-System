# 🎟️ Smart Event Management System

> **A MySQL-based database project for managing events, venues,
> organizers, attendees, ticket bookings, payments, and analytical
> reports.**

------------------------------------------------------------------------

## 📌 Project Overview

The **Smart Event Management System** is a relational database project
developed using **MySQL**.

The system is designed to help event organizers manage:

-   🎪 Events and venues
-   👤 Organizers and attendees
-   🎫 Ticket bookings
-   💳 Payment transactions
-   📊 Revenue and attendance analysis
-   📈 Reports using advanced SQL features

The project demonstrates important SQL concepts including:

**CRUD Operations, WHERE, HAVING, LIMIT, AND/OR/NOT, ORDER BY, GROUP BY,
Aggregate Functions, Primary Keys, Foreign Keys, JOINs, Subqueries, Date
& Time Functions, String Functions, Window Functions, and CASE
Expressions.**

------------------------------------------------------------------------

## 🎯 Project Objective

The main objective is to build a database system that allows event
organizers to:

1.  Manage events and venues.
2.  Handle attendee registrations and ticket sales.
3.  Track successful, failed, and pending payments.
4.  Generate useful reports about revenue, attendance, and event demand.
5.  Demonstrate both basic and advanced MySQL queries.

------------------------------------------------------------------------

# 🗂️ Database Structure

The project contains **6 relational tables**:

  Table          Purpose
  -------------- ------------------------------
  `Events`       Stores event information
  `Venues`       Stores venue details
  `Organizers`   Stores organizer information
  `Attendees`    Stores attendee information
  `Tickets`      Stores ticket bookings
  `Payments`     Stores payment transactions

### 🔗 Main Relationships

``` text
Organizers
     │
     │ 1 : Many
     ▼
  Events ───────────► Venues
     │
     │ 1 : Many
     ▼
  Tickets ◄──────── Attendees
     │
     │ 1 : 1 / Many
     ▼
 Payments
```

------------------------------------------------------------------------

# 🧱 Table Details

## 1. Events

Stores information about every event.

  Column              Description
  ------------------- ---------------------------
  `event_id`          Primary key
  `event_name`        Name of event
  `event_date`        Event date
  `venue_id`          Foreign key to Venues
  `organizer_id`      Foreign key to Organizers
  `ticket_price`      Price of one ticket
  `total_seats`       Total seats
  `available_seats`   Available seats

------------------------------------------------------------------------

## 2. Venues

Stores information about event locations.

  Column         Description
  -------------- ----------------
  `venue_id`     Primary key
  `venue_name`   Venue name
  `location`     City/location
  `capacity`     Venue capacity

------------------------------------------------------------------------

## 3. Organizers

Stores event organizer information.

  Column             Description
  ------------------ ----------------
  `organizer_id`     Primary key
  `organizer_name`   Organizer name
  `contact_email`    Email address
  `phone_number`     Contact number

------------------------------------------------------------------------

## 4. Attendees

Stores people attending events.

  Column           Description
  ---------------- ----------------
  `attendee_id`    Primary key
  `name`           Attendee name
  `email`          Email address
  `phone_number`   Contact number

------------------------------------------------------------------------

## 5. Tickets

Stores event bookings.

  Column           Description
  ---------------- ---------------------------------
  `ticket_id`      Primary key
  `event_id`       Foreign key
  `attendee_id`    Foreign key
  `booking_date`   Date of booking
  `status`         Confirmed / Cancelled / Pending

A `UNIQUE(event_id, attendee_id)` constraint prevents the same attendee
from booking the same event more than once.

------------------------------------------------------------------------

## 6. Payments

Stores payment information.

  Column             Description
  ------------------ ----------------------------
  `payment_id`       Primary key
  `ticket_id`        Foreign key
  `amount_paid`      Amount paid
  `payment_status`   Success / Failed / Pending
  `payment_date`     Payment date and time

------------------------------------------------------------------------
## 🎥 Video Demonstration

[![Watch Video](https://img.shields.io/badge/🎥-Watch_Video-red?style=for-the-badge)](video)

# 🛠️ SQL Concepts Implemented

## 1️⃣ CRUD Operations

CRUD means:

-   **C**reate
-   **R**ead
-   **U**pdate
-   **D**elete

### INSERT --- Add an event

``` sql
INSERT INTO Events
VALUES
(6,'AI Workshop','2026-12-28',1,1,1200,500,500);
```

**Purpose:** Adds a new event to the `Events` table.

### UPDATE --- Modify event information

``` sql
UPDATE Events
SET ticket_price = 1300
WHERE event_id = 6;
```

**Purpose:** Changes the ticket price of a specific event.

### DELETE --- Remove an event

``` sql
DELETE FROM Events
WHERE event_id = 6;
```

**Purpose:** Deletes the selected event.

### SEARCH --- Find an event

``` sql
SELECT *
FROM Events
WHERE event_name LIKE '%AI%';
```

**Purpose:** Searches for events whose names contain `AI`.

------------------------------------------------------------------------

# 2️⃣ WHERE, HAVING and LIMIT

## Upcoming events in a specific city

``` sql
SELECT e.event_name, e.event_date, v.location
FROM Events e
JOIN Venues v
ON e.venue_id = v.venue_id
WHERE v.location = 'Ahmedabad'
AND e.event_date >= CURDATE();
```

**Explanation:**\
Combines `Events` and `Venues`, then displays future events in
Ahmedabad.

### Top 5 highest revenue-generating events

``` sql
SELECT
    e.event_name,
    SUM(p.amount_paid) AS total_revenue
FROM Events e
JOIN Tickets t
ON e.event_id = t.event_id
JOIN Payments p
ON t.ticket_id = p.ticket_id
WHERE p.payment_status = 'Success'
GROUP BY e.event_id, e.event_name
ORDER BY total_revenue DESC
LIMIT 5;
```

**Explanation:**

-   `SUM()` calculates revenue.
-   `GROUP BY` groups revenue by event.
-   `ORDER BY DESC` sorts highest to lowest.
-   `LIMIT 5` returns only five events.

### Tickets booked in the last 7 days

``` sql
SELECT DISTINCT
    a.attendee_id,
    a.name
FROM Attendees a
JOIN Tickets t
ON a.attendee_id = t.attendee_id
WHERE t.booking_date >= CURDATE() - INTERVAL 7 DAY;
```

**Purpose:** Finds attendees who booked tickets during the previous
seven days.

------------------------------------------------------------------------

# 3️⃣ AND, OR and NOT Operators

## December events with more than 50% seats available

``` sql
SELECT *
FROM Events
WHERE MONTH(event_date) = 12
AND available_seats > total_seats * 0.50;
```

**Explanation:** Both conditions must be true because `AND` is used.

## Attendees who booked a ticket OR have a pending payment

``` sql
SELECT DISTINCT
    a.attendee_id,
    a.name
FROM Attendees a
LEFT JOIN Tickets t
ON a.attendee_id = t.attendee_id
LEFT JOIN Payments p
ON t.ticket_id = p.ticket_id
WHERE t.ticket_id IS NOT NULL
OR p.payment_status = 'Pending';
```

**Explanation:** `OR` returns attendees satisfying either condition.

## Events that are NOT fully booked

``` sql
SELECT *
FROM Events
WHERE NOT available_seats = 0;
```

**Purpose:** Shows events that still have seats available.

------------------------------------------------------------------------

# 4️⃣ ORDER BY and GROUP BY

## Sort events by date

``` sql
SELECT *
FROM Events
ORDER BY event_date ASC;
```

**Purpose:** Displays events from earliest to latest date.

## Count attendees per event

``` sql
SELECT
    e.event_name,
    COUNT(t.attendee_id) AS total_attendees
FROM Events e
LEFT JOIN Tickets t
ON e.event_id = t.event_id
GROUP BY e.event_id, e.event_name;
```

**Purpose:** Counts how many attendees are registered for each event.

## Total revenue per event

``` sql
SELECT
    e.event_name,
    SUM(p.amount_paid) AS total_revenue
FROM Events e
JOIN Tickets t
ON e.event_id = t.event_id
JOIN Payments p
ON t.ticket_id = p.ticket_id
WHERE p.payment_status = 'Success'
GROUP BY e.event_id, e.event_name;
```

**Purpose:** Calculates successful payment revenue for every event.

------------------------------------------------------------------------

# 5️⃣ Aggregate Functions

The project uses:

-   `SUM()` --- total
-   `AVG()` --- average
-   `MAX()` --- maximum
-   `MIN()` --- minimum
-   `COUNT()` --- number of records

### Total revenue

``` sql
SELECT SUM(amount_paid) AS total_revenue
FROM Payments
WHERE payment_status = 'Success';
```

### Event with the highest number of attendees

``` sql
SELECT
    e.event_name,
    COUNT(t.attendee_id) AS total_attendees
FROM Events e
JOIN Tickets t
ON e.event_id = t.event_id
GROUP BY e.event_id, e.event_name
ORDER BY total_attendees DESC
LIMIT 1;
```

### Average ticket price

``` sql
SELECT AVG(ticket_price) AS average_ticket_price
FROM Events;
```

These queries demonstrate how aggregate functions can generate
event-management statistics.

------------------------------------------------------------------------

# 6️⃣ Primary Key and Foreign Key Relationships

### Primary Keys

Each table has a unique identifier:

``` text
Events       → event_id
Venues       → venue_id
Organizers   → organizer_id
Attendees    → attendee_id
Tickets      → ticket_id
Payments     → payment_id
```

### Foreign Keys

``` text
Events.venue_id
        ↓
Venues.venue_id

Events.organizer_id
        ↓
Organizers.organizer_id

Tickets.event_id
        ↓
Events.event_id

Tickets.attendee_id
        ↓
Attendees.attendee_id

Payments.ticket_id
        ↓
Tickets.ticket_id
```

### Prevent duplicate booking

``` sql
UNIQUE(event_id, attendee_id)
```

**Purpose:** Prevents one attendee from booking the same event multiple
times.

------------------------------------------------------------------------

# 7️⃣ JOIN Operations

## INNER JOIN

``` sql
SELECT
    e.event_id,
    e.event_name,
    e.event_date,
    v.venue_name,
    v.location
FROM Events e
INNER JOIN Venues v
ON e.venue_id = v.venue_id;
```

**Purpose:** Displays event information together with its venue
information.

------------------------------------------------------------------------

## LEFT JOIN

``` sql
SELECT
    a.attendee_id,
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
```

**Purpose:** Finds attendees who booked a ticket but did not complete
successful payment.

------------------------------------------------------------------------

## RIGHT JOIN

``` sql
SELECT
    e.event_id,
    e.event_name
FROM Tickets t
RIGHT JOIN Events e
ON t.event_id = e.event_id
WHERE t.attendee_id IS NULL;
```

**Purpose:** Finds events without attendees.

------------------------------------------------------------------------

## FULL OUTER JOIN

MySQL does not directly support `FULL OUTER JOIN`, so it is implemented
using `LEFT JOIN + RIGHT JOIN + UNION`.

``` sql
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
```

**Purpose:** Combines matching and non-matching records from both sides.

------------------------------------------------------------------------

# 8️⃣ Subqueries

## Events with revenue above average

``` sql
SELECT
    e.event_id,
    e.event_name,
    SUM(p.amount_paid) AS total_revenue
FROM Events e
JOIN Tickets t
ON e.event_id = t.event_id
JOIN Payments p
ON t.ticket_id = p.ticket_id
WHERE p.payment_status = 'Success'
GROUP BY e.event_id, e.event_name
HAVING SUM(p.amount_paid) >
(
    SELECT AVG(amount_paid)
    FROM Payments
    WHERE payment_status = 'Success'
);
```

**Purpose:** Compares event revenue with the average successful payment
amount.

## Attendees who booked multiple events

``` sql
SELECT
    a.attendee_id,
    a.name,
    COUNT(DISTINCT t.event_id) AS total_events
FROM Attendees a
JOIN Tickets t
ON a.attendee_id = t.attendee_id
GROUP BY a.attendee_id, a.name
HAVING COUNT(DISTINCT t.event_id) > 1;
```

**Purpose:** Identifies attendees who have booked more than one event.

## Organizers who managed more than 3 events

``` sql
SELECT
    o.organizer_id,
    o.organizer_name,
    COUNT(e.event_id) AS total_events
FROM Organizers o
JOIN Events e
ON o.organizer_id = e.organizer_id
GROUP BY o.organizer_id, o.organizer_name
HAVING COUNT(e.event_id) > 3;
```

**Purpose:** Finds organizers managing more than three events.

------------------------------------------------------------------------

# 9️⃣ Date & Time Functions

## Extract month

``` sql
SELECT
    event_name,
    event_date,
    MONTH(event_date) AS event_month
FROM Events;
```

**Purpose:** Extracts the month number from `event_date`.

## Calculate remaining days

``` sql
SELECT
    event_name,
    event_date,
    DATEDIFF(event_date, CURDATE()) AS days_remaining
FROM Events
WHERE event_date >= CURDATE();
```

**Purpose:** Calculates the number of days remaining before an upcoming
event.

## Format payment date

``` sql
SELECT
    payment_id,
    DATE_FORMAT(payment_date,'%Y-%m-%d %H:%i:%s')
    AS formatted_payment_date
FROM Payments;
```

**Purpose:** Displays payment date and time in the required
`YYYY-MM-DD HH:MM:SS` format.

------------------------------------------------------------------------

# 🔟 String Manipulation Functions

## Convert organizer names to uppercase

``` sql
SELECT
    organizer_name,
    UPPER(organizer_name) AS uppercase_name
FROM Organizers;
```

**Purpose:** Converts organizer names into uppercase.

## Remove extra spaces

``` sql
SELECT
    name,
    TRIM(name) AS cleaned_name
FROM Attendees;
```

**Purpose:** Removes leading and trailing spaces.

## Replace NULL email

``` sql
SELECT
    name,
    COALESCE(email,'Not Provided') AS email
FROM Attendees;
```

**Purpose:** Displays `Not Provided` whenever an attendee's email is
`NULL`.

------------------------------------------------------------------------

# 1️⃣1️⃣ Window Functions

## Rank events by total revenue

``` sql
SELECT
    e.event_name,
    SUM(p.amount_paid) AS total_revenue,
    RANK() OVER (
        ORDER BY SUM(p.amount_paid) DESC
    ) AS revenue_rank
FROM Events e
JOIN Tickets t
ON e.event_id = t.event_id
JOIN Payments p
ON t.ticket_id = p.ticket_id
WHERE p.payment_status = 'Success'
GROUP BY e.event_id, e.event_name;
```

**Purpose:** Gives each event a revenue rank.

## Cumulative ticket sales

``` sql
SELECT
    booking_date,
    COUNT(*) AS tickets_sold,
    SUM(COUNT(*)) OVER (
        ORDER BY booking_date
    ) AS cumulative_sales
FROM Tickets
GROUP BY booking_date
ORDER BY booking_date;
```

**Purpose:** Shows ticket sales accumulated over booking dates.

## Running attendees per event

``` sql
SELECT
    e.event_name,
    t.booking_date,
    COUNT(*) AS attendees,
    SUM(COUNT(*)) OVER (
        PARTITION BY e.event_id
        ORDER BY t.booking_date
    ) AS running_attendees
FROM Events e
JOIN Tickets t
ON e.event_id = t.event_id
GROUP BY e.event_id, e.event_name, t.booking_date;
```

**Purpose:** Shows the running number of attendees registered for each
event.

------------------------------------------------------------------------

# 1️⃣2️⃣ CASE Expressions

## Event Demand Classification

``` sql
SELECT
    event_name,
    available_seats,
    total_seats,
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
```

### Classification Logic

  Available Seats   Category
  ----------------- -----------------
  Less than 20%     High Demand
  20% to 50%        Moderate Demand
  Above 50%         Low Demand

------------------------------------------------------------------------

## Payment Status Classification

``` sql
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
```

**Purpose:** Converts database payment statuses into readable
categories.

------------------------------------------------------------------------

# 📊 SQL Features Covered

  Requirement          SQL Feature
  -------------------- -------------------------------------
  CRUD                 INSERT, UPDATE, DELETE, SELECT
  Filtering            WHERE
  Group filtering      HAVING
  Result limit         LIMIT
  Conditions           AND, OR, NOT
  Sorting              ORDER BY
  Grouping             GROUP BY
  Calculations         SUM, AVG, MAX, MIN, COUNT
  Relationships        PRIMARY KEY, FOREIGN KEY
  Combining tables     INNER, LEFT, RIGHT, FULL OUTER JOIN
  Advanced filtering   Subqueries
  Date analysis        MONTH, DATEDIFF, DATE_FORMAT
  Text processing      UPPER, TRIM, COALESCE
  Advanced analysis    Window Functions
  Conditional logic    CASE

------------------------------------------------------------------------

# 🧠 Key Learning Outcomes

After completing this project, the following SQL concepts are
demonstrated:

-   Database and table creation
-   Relational database design
-   Primary and foreign key relationships
-   Data insertion and modification
-   Data filtering and sorting
-   Aggregation and grouping
-   Multiple-table joins
-   Subqueries
-   Date and time manipulation
-   String manipulation
-   Window functions
-   Conditional expressions
-   Event revenue analysis
-   Attendance analysis
-   Payment tracking

------------------------------------------------------------------------

# 🚀 Technology Used

-   **Database:** MySQL
-   **Language:** SQL
-   **Tools:** MySQL Workbench / phpMyAdmin / XAMPP
-   **Project Type:** Relational Database Management System

------------------------------------------------------------------------

# 📁 Suggested Project Structure

``` text
Smart-Event-Management-System/
│
├── README.md
├── smart_event_management.sql
├── ER_Diagram.png
└── Screenshots/
    ├── database.png
    ├── tables.png
    ├── joins.png
    ├── aggregate_functions.png
    └── window_functions.png
```

------------------------------------------------------------------------

# 👨‍💻 Project Summary

**Smart Event Management System** demonstrates how MySQL can be used to
build a structured event-management database and perform both
operational and analytical tasks.

The project combines relational database design with advanced SQL
techniques to manage **events, venues, organizers, attendees, tickets,
and payments** in one integrated system.

------------------------------------------------------------------------

## ⭐ Project Highlights

``` text
✔ 6 Relational Tables
✔ Primary & Foreign Keys
✔ CRUD Operations
✔ Multiple JOIN Types
✔ Aggregate Functions
✔ Subqueries
✔ Date & Time Functions
✔ String Functions
✔ Window Functions
✔ CASE Expressions
✔ Revenue Analysis
✔ Attendance Analysis
✔ Payment Tracking
```

------------------------------------------------------------------------

👨‍💻 Author
Name: Kush Kumar

