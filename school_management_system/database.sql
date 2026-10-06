-- School Management Portal - production-oriented XAMPP schema
-- Import in phpMyAdmin. No payment gateway is included.
CREATE DATABASE IF NOT EXISTS school_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE school_db;
SET FOREIGN_KEY_CHECKS=0;
DROP TABLE IF EXISTS notification_logs, notification_queue, community_reactions, community_comments, community_posts, timetable_entries, audit_logs, messages, announcements, attendance, results, teacher_subjects, teacher_classes, student_parents, admissions, students, parents, teachers, subjects, classes, academic_terms, registration_sequences, users, settings;
SET FOREIGN_KEY_CHECKS=1;

CREATE TABLE settings (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 school_name VARCHAR(180) NOT NULL DEFAULT 'My School',
 school_code VARCHAR(30) NOT NULL DEFAULT 'SCH',
 school_email VARCHAR(180) NULL,
 school_phone VARCHAR(50) NULL,
 school_address TEXT NULL,
 logo VARCHAR(255) NULL,
 email_enabled TINYINT(1) NOT NULL DEFAULT 0,
 email_from VARCHAR(180) NULL,
 sms_enabled TINYINT(1) NOT NULL DEFAULT 0,
 sms_endpoint VARCHAR(500) NULL,
 sms_api_key VARCHAR(255) NULL,
 sms_sender_id VARCHAR(50) NULL,
 whatsapp_enabled TINYINT(1) NOT NULL DEFAULT 0,
 whatsapp_endpoint VARCHAR(500) NULL,
 whatsapp_token VARCHAR(500) NULL,
 whatsapp_phone_number_id VARCHAR(100) NULL,
 updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE users (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 username VARCHAR(100) NOT NULL UNIQUE,
 password_hash VARCHAR(255) NOT NULL,
 role ENUM('admin','teacher','student','parent') NOT NULL,
 full_name VARCHAR(180) NOT NULL,
 email VARCHAR(180) NULL UNIQUE,
 phone VARCHAR(50) NULL,
 status ENUM('active','inactive','locked') NOT NULL DEFAULT 'active',
 must_change_password TINYINT(1) NOT NULL DEFAULT 0,
 failed_login_attempts TINYINT UNSIGNED NOT NULL DEFAULT 0,
 locked_until DATETIME NULL,
 last_login_at DATETIME NULL,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 INDEX idx_users_role_status(role,status),
 INDEX idx_users_locked(locked_until)
) ENGINE=InnoDB;

CREATE TABLE registration_sequences (
 sequence_key VARCHAR(50) PRIMARY KEY,
 last_number INT UNSIGNED NOT NULL DEFAULT 0
) ENGINE=InnoDB;

CREATE TABLE classes (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 name VARCHAR(100) NOT NULL,
 section VARCHAR(100) NULL,
 level VARCHAR(100) NULL,
 capacity INT UNSIGNED DEFAULT 0,
 active TINYINT(1) NOT NULL DEFAULT 1,
 UNIQUE KEY uq_class(name,section)
) ENGINE=InnoDB;

CREATE TABLE academic_terms (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 session_name VARCHAR(30) NOT NULL,
 term_name ENUM('First Term','Second Term','Third Term') NOT NULL,
 start_date DATE NULL,
 end_date DATE NULL,
 is_current TINYINT(1) NOT NULL DEFAULT 0,
 UNIQUE KEY uq_term(session_name,term_name),
 INDEX idx_current(is_current)
) ENGINE=InnoDB;

CREATE TABLE subjects (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 code VARCHAR(30) NOT NULL UNIQUE,
 subject_name VARCHAR(120) NOT NULL,
 max_ca DECIMAL(5,2) NOT NULL DEFAULT 40,
 max_exam DECIMAL(5,2) NOT NULL DEFAULT 60,
 active TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB;

CREATE TABLE teachers (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 user_id INT UNSIGNED NOT NULL UNIQUE,
 staff_no VARCHAR(50) NOT NULL UNIQUE,
 qualification VARCHAR(180) NULL,
 hire_date DATE NULL,
 address TEXT NULL,
 FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE parents (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 user_id INT UNSIGNED NOT NULL UNIQUE,
 address TEXT NULL,
 occupation VARCHAR(150) NULL,
 FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE students (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 user_id INT UNSIGNED NULL UNIQUE,
 admission_no VARCHAR(50) NOT NULL UNIQUE,
 surname VARCHAR(100) NOT NULL,
 firstname VARCHAR(100) NOT NULL,
 othername VARCHAR(100) NULL,
 gender ENUM('Male','Female','Other') NULL,
 dob DATE NULL,
 class_id INT UNSIGNED NULL,
 phone VARCHAR(50) NULL,
 address TEXT NULL,
 photo VARCHAR(255) NULL,
 admission_date DATE NULL,
 status ENUM('active','inactive','graduated','withdrawn') NOT NULL DEFAULT 'active',
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE SET NULL,
 FOREIGN KEY(class_id) REFERENCES classes(id) ON DELETE SET NULL,
 INDEX idx_student_class_status(class_id,status),
 INDEX idx_student_status(status),
 INDEX idx_student_name(surname,firstname)
) ENGINE=InnoDB;

CREATE TABLE student_parents (
 student_id INT UNSIGNED NOT NULL,
 parent_id INT UNSIGNED NOT NULL,
 relationship VARCHAR(50) NOT NULL DEFAULT 'Parent/Guardian',
 is_primary TINYINT(1) NOT NULL DEFAULT 0,
 PRIMARY KEY(student_id,parent_id),
 FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE CASCADE,
 FOREIGN KEY(parent_id) REFERENCES parents(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE teacher_classes (
 teacher_id INT UNSIGNED NOT NULL,
 class_id INT UNSIGNED NOT NULL,
 PRIMARY KEY(teacher_id,class_id),
 FOREIGN KEY(teacher_id) REFERENCES teachers(id) ON DELETE CASCADE,
 FOREIGN KEY(class_id) REFERENCES classes(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE teacher_subjects (
 teacher_id INT UNSIGNED NOT NULL,
 subject_id INT UNSIGNED NOT NULL,
 PRIMARY KEY(teacher_id,subject_id),
 FOREIGN KEY(teacher_id) REFERENCES teachers(id) ON DELETE CASCADE,
 FOREIGN KEY(subject_id) REFERENCES subjects(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE results (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 student_id INT UNSIGNED NOT NULL,
 subject_id INT UNSIGNED NOT NULL,
 term_id INT UNSIGNED NOT NULL,
 ca_score DECIMAL(5,2) NOT NULL DEFAULT 0,
 exam_score DECIMAL(5,2) NOT NULL DEFAULT 0,
 total DECIMAL(5,2) GENERATED ALWAYS AS (ca_score + exam_score) STORED,
 grade VARCHAR(5) NULL,
 remarks VARCHAR(100) NULL,
 entered_by INT UNSIGNED NULL,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 UNIQUE KEY uq_result(student_id,subject_id,term_id),
 FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE CASCADE,
 FOREIGN KEY(subject_id) REFERENCES subjects(id) ON DELETE CASCADE,
 FOREIGN KEY(term_id) REFERENCES academic_terms(id) ON DELETE CASCADE,
 FOREIGN KEY(entered_by) REFERENCES users(id) ON DELETE SET NULL,
 INDEX idx_results_student_term(student_id,term_id),
 INDEX idx_results_term_subject(term_id,subject_id)
) ENGINE=InnoDB;

CREATE TABLE attendance (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 student_id INT UNSIGNED NOT NULL,
 class_id INT UNSIGNED NULL,
 attendance_date DATE NOT NULL,
 status ENUM('present','absent','late','excused') NOT NULL,
 note VARCHAR(255) NULL,
 recorded_by INT UNSIGNED NULL,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 UNIQUE KEY uq_attendance(student_id,attendance_date),
 FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE CASCADE,
 FOREIGN KEY(class_id) REFERENCES classes(id) ON DELETE SET NULL,
 FOREIGN KEY(recorded_by) REFERENCES users(id) ON DELETE SET NULL,
 INDEX idx_attendance_student_date(student_id,attendance_date),
 INDEX idx_attendance_class_date(class_id,attendance_date)
) ENGINE=InnoDB;

CREATE TABLE announcements (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 title VARCHAR(200) NOT NULL,
 body TEXT NOT NULL,
 audience ENUM('all','parents','students','teachers') NOT NULL DEFAULT 'all',
 published_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 expires_at DATETIME NULL,
 created_by INT UNSIGNED NULL,
 FOREIGN KEY(created_by) REFERENCES users(id) ON DELETE SET NULL,
 INDEX idx_announcements_audience(audience,published_at)
) ENGINE=InnoDB;

CREATE TABLE messages (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 sender_id INT UNSIGNED NOT NULL,
 recipient_id INT UNSIGNED NOT NULL,
 subject VARCHAR(200) NOT NULL,
 body TEXT NOT NULL,
 sent_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 read_at DATETIME NULL,
 FOREIGN KEY(sender_id) REFERENCES users(id) ON DELETE CASCADE,
 FOREIGN KEY(recipient_id) REFERENCES users(id) ON DELETE CASCADE,
 INDEX idx_recipient(recipient_id,read_at,sent_at),
 INDEX idx_sender(sender_id,sent_at)
) ENGINE=InnoDB;

CREATE TABLE admissions (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 application_no VARCHAR(50) NOT NULL UNIQUE,
 surname VARCHAR(100) NOT NULL,
 firstname VARCHAR(100) NOT NULL,
 othername VARCHAR(100) NULL,
 gender ENUM('Male','Female','Other') NULL,
 dob DATE NULL,
 applying_class VARCHAR(100) NULL,
 parent_name VARCHAR(180) NOT NULL,
 parent_email VARCHAR(180) NULL,
 parent_phone VARCHAR(50) NOT NULL,
 address TEXT NULL,
 status ENUM('submitted','under_review','accepted','rejected','enrolled') NOT NULL DEFAULT 'submitted',
 notes TEXT NULL,
 enrolled_student_id INT UNSIGNED NULL,
 submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 reviewed_at DATETIME NULL,
 reviewed_by INT UNSIGNED NULL,
 FOREIGN KEY(reviewed_by) REFERENCES users(id) ON DELETE SET NULL,
 FOREIGN KEY(enrolled_student_id) REFERENCES students(id) ON DELETE SET NULL,
 INDEX idx_admission_status(status),
 INDEX idx_admission_phone(parent_phone)
) ENGINE=InnoDB;

CREATE TABLE timetable_entries (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 class_id INT UNSIGNED NOT NULL,
 subject_id INT UNSIGNED NOT NULL,
 teacher_id INT UNSIGNED NOT NULL,
 term_id INT UNSIGNED NOT NULL,
 day_of_week TINYINT UNSIGNED NOT NULL,
 start_time TIME NOT NULL,
 end_time TIME NOT NULL,
 room VARCHAR(100) NULL,
 created_by INT UNSIGNED NULL,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 FOREIGN KEY(class_id) REFERENCES classes(id) ON DELETE CASCADE,
 FOREIGN KEY(subject_id) REFERENCES subjects(id) ON DELETE CASCADE,
 FOREIGN KEY(teacher_id) REFERENCES teachers(id) ON DELETE CASCADE,
 FOREIGN KEY(term_id) REFERENCES academic_terms(id) ON DELETE CASCADE,
 FOREIGN KEY(created_by) REFERENCES users(id) ON DELETE SET NULL,
 INDEX idx_timetable_class(term_id,class_id,day_of_week,start_time),
 INDEX idx_timetable_teacher(term_id,teacher_id,day_of_week,start_time)
) ENGINE=InnoDB;

CREATE TABLE community_posts (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 author_id INT UNSIGNED NOT NULL,
 title VARCHAR(200) NOT NULL,
 body TEXT NOT NULL,
 post_type ENUM('announcement','discussion') NOT NULL DEFAULT 'announcement',
 created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at DATETIME NULL,
 FOREIGN KEY(author_id) REFERENCES users(id) ON DELETE CASCADE,
 INDEX idx_community_posts_created(created_at)
) ENGINE=InnoDB;

CREATE TABLE community_comments (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 post_id BIGINT UNSIGNED NOT NULL,
 author_id INT UNSIGNED NOT NULL,
 body TEXT NOT NULL,
 created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(post_id) REFERENCES community_posts(id) ON DELETE CASCADE,
 FOREIGN KEY(author_id) REFERENCES users(id) ON DELETE CASCADE,
 INDEX idx_comments_post(post_id,created_at)
) ENGINE=InnoDB;

CREATE TABLE community_reactions (
 post_id BIGINT UNSIGNED NOT NULL,
 user_id INT UNSIGNED NOT NULL,
 reaction ENUM('like','helpful','celebrate') NOT NULL DEFAULT 'like',
 created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 PRIMARY KEY(post_id,user_id),
 FOREIGN KEY(post_id) REFERENCES community_posts(id) ON DELETE CASCADE,
 FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE notification_queue (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 user_id INT UNSIGNED NULL,
 channel ENUM('email','sms','whatsapp') NOT NULL,
 recipient VARCHAR(255) NOT NULL,
 subject VARCHAR(255) NULL,
 body TEXT NOT NULL,
 status ENUM('queued','processing','sent','failed') NOT NULL DEFAULT 'queued',
 attempts TINYINT UNSIGNED NOT NULL DEFAULT 0,
 available_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 locked_at DATETIME NULL,
 sent_at DATETIME NULL,
 last_error TEXT NULL,
 created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE SET NULL,
 INDEX idx_queue_worker(status,available_at),
 INDEX idx_queue_user(user_id,created_at)
) ENGINE=InnoDB;

CREATE TABLE notification_logs (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 queue_id BIGINT UNSIGNED NULL,
 channel VARCHAR(30) NOT NULL,
 recipient VARCHAR(255) NOT NULL,
 status VARCHAR(30) NOT NULL,
 provider_response TEXT NULL,
 created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(queue_id) REFERENCES notification_queue(id) ON DELETE SET NULL,
 INDEX idx_notification_logs_created(created_at)
) ENGINE=InnoDB;

CREATE TABLE audit_logs (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 user_id INT UNSIGNED NULL,
 action VARCHAR(100) NOT NULL,
 entity VARCHAR(100) NULL,
 entity_id BIGINT UNSIGNED NULL,
 details TEXT NULL,
 ip_address VARCHAR(45) NULL,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE SET NULL,
 INDEX idx_audit_created(created_at),
 INDEX idx_audit_user(user_id)
) ENGINE=InnoDB;

INSERT INTO settings (school_name,school_code,school_email,school_phone,school_address)
VALUES ('My School','SCH',NULL,NULL,NULL);

INSERT INTO classes (name,section,level,capacity) VALUES
('JSS1','A','Junior Secondary',40),
('JSS1','B','Junior Secondary',40),
('JSS1','C','Junior Secondary',40),
('JSS1','D','Junior Secondary',40),
('JSS2','A','Junior Secondary',40),
('JSS2','B','Junior Secondary',40),
('JSS2','C','Junior Secondary',40),
('JSS2','D','Junior Secondary',40),
('JSS3','A','Junior Secondary',40),
('JSS3','B','Junior Secondary',40),
('JSS3','C','Junior Secondary',40),
('JSS3','D','Junior Secondary',40),
('SSS1','A','Senior Secondary',40),
('SSS1','B','Senior Secondary',40),
('SSS1','C','Senior Secondary',40),
('SSS1','D','Senior Secondary',40),
('SSS2','A','Senior Secondary',40),
('SSS2','B','Senior Secondary',40),
('SSS2','C','Senior Secondary',40),
('SSS2','D','Senior Secondary',40),
('SSS3','A','Senior Secondary',40),
('SSS3','B','Senior Secondary',40),
('SSS3','C','Senior Secondary',40),
('SSS3','D','Senior Secondary',40);

INSERT INTO subjects (code,subject_name,max_ca,max_exam) VALUES
('ENG','English Language',40,60),
('MTH','Mathematics',40,60),
('CIV','Civic Education',40,60),
('BSC','Basic Science',40,60),
('BST','Basic Technology',40,60),
('ICT','Computer Studies',40,60),
('AGR','Agricultural Science',40,60),
('BUS','Business Studies',40,60),
('CRS','Christian Religious Studies',40,60),
('IRS','Islamic Religious Studies',40,60),
('HIS','History',40,60),
('GEO','Geography',40,60),
('YOR','Yoruba',40,60),('IGB','Igbo',40,60),('HAU','Hausa',40,60),
('LIT','Literature in English',40,60),
('GOV','Government',40,60),
('ECO','Economics',40,60),
('ACC','Accounting',40,60),
('PHY','Physics',40,60);

INSERT INTO academic_terms (session_name,term_name,start_date,end_date,is_current)
VALUES ('2026/2027','First Term','2026-09-01','2026-12-18',1);

INSERT INTO registration_sequences(sequence_key,last_number) VALUES ('student:2026',0),('teacher:2026',0);

-- Initial administrator. Change immediately after first login.
-- Username: admin / Password: Admin@12345
INSERT INTO users (username,password_hash,role,full_name,status,must_change_password)
VALUES ('admin','$2y$12$NPNzlytTnjMqg5h7X3csqeqVtxMSvClEbphMuuZSbxwRHftVUGdgK','admin','School Administrator','active',1);
