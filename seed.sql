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
INSERT INTO records (kind, title, status, notes) VALUES
  ('customer', 'Sam Example', 'open', 'Weekly service, Mondays. 16x32 pool, salt system.'),
  ('customer', 'Robin Sample', 'open', 'Spa only. Heater repair pending.'),
  ('job', 'Replace pump seal — Sam Example', 'done', 'Parts on the truck.'),
  ('job', 'Heater diagnosis — Robin Sample', 'open', 'Booked through the calendar.');

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
