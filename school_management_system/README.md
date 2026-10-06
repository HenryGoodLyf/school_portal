# School Management Portal — XAMPP

PHP + MySQL school management portal for Nigerian secondary schools. No payment gateway is included.

## Main capabilities

- Administrator-controlled student and teacher registration
- Automatically generated school registration numbers, e.g. `SCH/STD/2026/0001` and `SCH/STF/2026/0001`
- Administrator-generated first passwords with mandatory password change on first login
- Student admission applications and administrator enrolment
- Class assignment and teacher/class/subject assignments
- Results and attendance
- Timetables for administrators and assigned teachers, with class/teacher overlap checks
- Parent/guardian linking
- School announcements and community discussions/comments/reactions
- Internal messaging
- Email/SMS/WhatsApp notification queue and worker
- Editable school name, school code, contact details and logo
- Audit log and basic account lockout
- Indexed result/attendance queries and paginated student/parent result views

## XAMPP installation

1. Extract this folder into `C:\xampp\htdocs\school_management_system`.
2. Start Apache and MySQL in XAMPP.
3. Open phpMyAdmin and import `database.sql`.
4. Open `http://localhost/school_management_system/`.
5. Sign in with the initial administrator account below.
6. Immediately change the password.
7. Open **School Settings** and replace the school name, code, logo, contact information and notification provider settings.

## Initial administrator

Username: `admin`

Initial password: `Adm!2026#X7pQ`

This account is marked to require a password change.

## Registration numbers

There is no single nationwide Nigerian secondary-school registration-number format. The system therefore uses a configurable school code plus year and sequential number. Change the school code in **School Settings** before registering students/teachers.

Examples:

- Student: `SCH/STD/2026/0001`
- Teacher: `SCH/STF/2026/0001`

Numbers are generated transactionally to avoid duplicate IDs when two administrators register people at the same time.

## Notifications

The portal writes outbound email/SMS/WhatsApp messages to `notification_queue`. Run:

`php cron/notifications_worker.php`

from a protected scheduled task/cron job. Email uses PHP `mail()`. SMS uses the configured JSON HTTP endpoint. WhatsApp uses the configured WhatsApp-compatible endpoint/token and text-message payload. Provider accounts, sender IDs, templates and regulatory requirements remain provider-specific.

For internet deployment, keep provider credentials outside source control and preferably supply them through environment variables or a secrets manager rather than committing them to the database.

## Security notes

- PDO prepared statements are used for database writes/queries.
- POST forms use CSRF tokens.
- Sessions use HttpOnly/SameSite cookies and regenerate on login.
- Login failures are rate-limited with temporary account locking.
- First passwords are hashed and forced to change.
- Output is HTML-escaped.
- Uploads accept only PNG/JPEG/WEBP and are limited to 2MB; PHP execution is denied in the upload directory.
- Role checks and teacher assignment checks are enforced server-side.
- Timetable conflicts are checked before insertion.
- Audit events are recorded for important administrative actions.

Before public internet deployment, use HTTPS, a non-root MySQL account, environment-held secrets, automated backups, a proper SMTP service, provider-specific SMS/WhatsApp configuration, server-level rate limiting/WAF, and a final infrastructure penetration test.


## October 2026 update
- Student accounts can view their class timetable from the Timetable menu.
- Admin Results now loads all active students in a selected class arm and supports class-wide CA/exam entry.
- Admin-only transcript generation filters by student and academic session; use Print / Save as PDF in the browser.
- Standard class arms JSS1A–JSS3D and SSS1A–SSS3D and 20 common Nigerian secondary subjects are seeded.
- Parent-to-student linking controls and student-linked parent pages have been removed. Parent communication/announcements remain available without access to student records.
- For an existing database, back it up and import `database_update_2026_10.sql`; for a fresh install, use `database.sql`.

CSV score upload template: `results_upload_template.csv`. Replace the sample registration number and scores; upload after selecting the correct class arm, subject and term.
