-- Apply this to an EXISTING school_db from the previous release. Backup first.
USE school_db;
-- Normalize the original starter class names before adding the complete arm list.
UPDATE classes SET name='JSS1' WHERE name='JSS 1';
UPDATE classes SET name='JSS2' WHERE name='JSS 2';
UPDATE classes SET name='JSS3' WHERE name='JSS 3';
UPDATE classes SET name='SSS1' WHERE name IN ('SS 1','SSS 1');
UPDATE classes SET name='SSS2' WHERE name IN ('SS 2','SSS 2');
UPDATE classes SET name='SSS3' WHERE name IN ('SS 3','SSS 3');
UPDATE subjects SET code='MTH' WHERE code='MATH' AND NOT EXISTS (SELECT 1 FROM (SELECT code FROM subjects WHERE code='MTH') x);
-- Add the full set of standard JSS/SSS arms; duplicate entries are ignored.
INSERT IGNORE INTO classes(name,section,level,capacity) VALUES
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
-- Seed 20 common Nigerian secondary-school subjects without duplicating existing subject codes.
INSERT IGNORE INTO subjects(code,subject_name,max_ca,max_exam) VALUES
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
-- Parent-child linking UI has been removed. Existing historical link records are retained for data safety.
