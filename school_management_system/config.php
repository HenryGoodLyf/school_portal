<?php
declare(strict_types=1);
const APP_BASE_URL = '/school_management_system';
const DB_HOST = '127.0.0.1';
const DB_NAME = 'school_db';
const DB_USER = 'root';
const DB_PASS = '';

$isHttps=!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off';
session_name('school_portal');
session_set_cookie_params(['httponly'=>true,'samesite'=>'Lax','secure'=>$isHttps,'path'=>'/']);
if (session_status() !== PHP_SESSION_ACTIVE) session_start();
header('X-Frame-Options: SAMEORIGIN');
header('X-Content-Type-Options: nosniff');
header('Referrer-Policy: strict-origin-when-cross-origin');
header("Content-Security-Policy: default-src 'self' https://cdn.jsdelivr.net; img-src 'self' data: https:; style-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net; script-src 'self' https://cdn.jsdelivr.net; font-src 'self' https://cdn.jsdelivr.net; frame-ancestors 'self'");
try { $pdo = new PDO('mysql:host='.DB_HOST.';dbname='.DB_NAME.';charset=utf8mb4', DB_USER, DB_PASS, [PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC,PDO::ATTR_EMULATE_PREPARES=>false,PDO::MYSQL_ATTR_INIT_COMMAND=>"SET NAMES utf8mb4"]); }
catch (PDOException $e) { http_response_code(500); exit('Database connection failed. Check config.php and make sure MySQL is running.'); }
