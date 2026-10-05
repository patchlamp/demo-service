-- The golden rows: what the demo's database holds after `demo reset` (every
-- night at 04:10). Dates are relative to the day the reset runs, so the
-- calendar always starts tomorrow. Fictional people, 555 numbers, example.com.
-- Open times: Mon, Wed and Fri at 9am and 1pm for the next three weeks. No
-- Tuesdays, so "add Tuesday 9am as a booking slot" is a real change.
WITH RECURSIVE d(n) AS (SELECT 1 UNION ALL SELECT n + 1 FROM d WHERE n < 21)
INSERT INTO booking_slots (starts_at, minutes, capacity, label)
SELECT date('now', '-6 hours', '+' || n || ' days') || 'T' || t.hm, 60, 1, t.label
  FROM d, (SELECT '09:00' AS hm, 'Weekly service' AS label UNION ALL SELECT '13:00', 'Repair visit') AS t
 WHERE strftime('%w', date('now', '-6 hours', '+' || n || ' days')) IN ('1', '3', '5')
 ORDER BY 1;
INSERT INTO bookings (slot_id, starts_at, name, email, phone, notes, status)
SELECT id, starts_at, 'Sam Example', 'sam@example.com', '555-0142', 'Gate code is on the side door.', 'confirmed'
  FROM booking_slots ORDER BY starts_at LIMIT 1;
INSERT INTO bookings (slot_id, starts_at, name, email, phone, notes, status)
SELECT id, starts_at, 'Robin Sample', 'robin@example.com', '555-0187', 'Heater clicks but will not light.', 'requested'
  FROM booking_slots WHERE label = 'Repair visit' ORDER BY starts_at LIMIT 1;
INSERT INTO submissions (form, name, email, phone, message, fields, status) VALUES
  ('quote', 'Jordan Placeholder', 'jordan@example.com', '555-0110', 'Quote for weekly service, 18x36 pool, June to September.',
   '{"name":"Jordan Placeholder","email":"jordan@example.com","phone":"555-0110","message":"Quote for weekly service, 18x36 pool, June to September."}', 'new'),
  ('quote', 'Casey Demo', 'casey@example.com', NULL, 'New variable-speed pump, the old one is loud.',
   '{"name":"Casey Demo","email":"casey@example.com","message":"New variable-speed pump, the old one is loud."}', 'replied');
-- The customer book (B122): four customers, the jobs done for them. Two were
-- seen lately, two not in 90 days, so "who haven't I seen in 90 days" has an
-- answer. Phones and emails match the bookings above.
INSERT INTO customers (name, phone, phone_key, email, address, notes, tags, source, last_seen) VALUES
  ('Sam Example', '555-0142', '5550142', 'sam@example.com', NULL, 'Weekly service, Mondays. 16x32 pool, salt system.', 'weekly', 'records', date('now', '-6 hours', '-7 days')),
  ('Robin Sample', '555-0187', '5550187', 'robin@example.com', NULL, 'Spa only. Heater repair pending.', 'spa', 'records', date('now', '-6 hours', '-40 days')),
  ('Parker Example', '555-0171', '5550171', 'parker@example.com', NULL, 'Green-to-clean last spring; asked about weekly service.', NULL, 'admin', date('now', '-6 hours', '-130 days')),
  ('Jamie Placeholder', '555-0164', '5550164', 'jamie@example.com', NULL, 'Season close every October.', 'seasonal', 'admin', date('now', '-6 hours', '-110 days'));
INSERT INTO jobs (customer_id, customer_name, date, what, amount_cents, status, notes, source) VALUES
  (1, 'Sam Example', date('now', '-6 hours', '-7 days'), 'Replace pump seal', 18000, 'done', 'Parts on the truck.', 'admin'),
  (2, 'Robin Sample', date('now', '-6 hours', '-40 days'), 'Spa clean', 9500, 'done', NULL, 'admin'),
  (2, 'Robin Sample', date('now', '-6 hours', '+5 days'), 'Heater diagnosis', NULL, 'booked', 'Booked through the calendar.', 'admin'),
  (3, 'Parker Example', date('now', '-6 hours', '-130 days'), 'Green-to-clean', 35000, 'done', NULL, 'admin'),
  (4, 'Jamie Placeholder', date('now', '-6 hours', '-110 days'), 'Season close', 25000, 'done', NULL, 'admin');

-- Routes (B40): a week of stops around today; today is under way.
WITH s(k, stop, customer, job, area, status) AS (VALUES
  (-1, 1, 'Sam Example', 'Weekly service', 'North bench', 'done'),
  (-1, 2, 'Casey Demo', 'Weekly service', 'North bench', 'done'),
  (-1, 3, 'Jordan Placeholder', 'Filter clean', 'Old town', 'done'),
  (-1, 4, 'Avery Sample', 'Weekly service', 'Old town', 'skipped'),
  (0, 1, 'Robin Sample', 'Heater check', 'East hills', 'done'),
  (0, 2, 'Morgan Example', 'Weekly service', 'East hills', 'done'),
  (0, 3, 'Riley Placeholder', 'Weekly service', 'East hills', 'done'),
  (0, 4, 'Quinn Demo', 'Green-to-clean', 'Canal road', 'skipped'),
  (0, 5, 'Taylor Sample', 'Weekly service', 'Canal road', 'to do'),
  (0, 6, 'Drew Example', 'Salt cell clean', 'Canal road', 'to do'),
  (0, 7, 'Jamie Placeholder', 'Weekly service', 'North bench', 'to do'),
  (1, 1, 'Sam Example', 'Weekly service', 'North bench', 'to do'),
  (1, 2, 'Casey Demo', 'Pump seal', 'North bench', 'to do'),
  (1, 3, 'Avery Sample', 'Weekly service', 'Old town', 'to do'),
  (2, 1, 'Morgan Example', 'Weekly service', 'East hills', 'to do'),
  (2, 2, 'Drew Example', 'Weekly service', 'Canal road', 'to do'))
INSERT INTO routes (day, stop, customer, job, area, status)
SELECT date('now', '-6 hours', k || ' days'), stop, customer, job, area, status FROM s;
