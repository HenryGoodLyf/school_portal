<?php
function e(?string $value): string { return htmlspecialchars($value ?? '', ENT_QUOTES, 'UTF-8'); }
function redirect(string $url): never { header('Location: '.$url); exit; }
function flash(string $key, ?string $value=null): ?string { if($value!==null){$_SESSION['flash'][$key]=$value;return null;} $v=$_SESSION['flash'][$key]??null; unset($_SESSION['flash'][$key]); return $v; }
function csrf_token(): string { if (empty($_SESSION['csrf'])) $_SESSION['csrf'] = bin2hex(random_bytes(32)); return $_SESSION['csrf']; }
function verify_csrf(): void { if (!hash_equals($_SESSION['csrf'] ?? '', $_POST['csrf'] ?? '')) { http_response_code(419); exit('Invalid request token.'); } }
function user(): ?array { return $_SESSION['user'] ?? null; }
function require_login(): void { if (!user()) redirect(APP_BASE_URL.'/login.php'); if (!empty(user()['must_change_password']) && basename($_SERVER['PHP_SELF'])!=='account.php' && basename($_SERVER['PHP_SELF'])!=='logout.php') redirect(APP_BASE_URL.'/account.php?first=1'); }
function require_role(array $roles): void { require_login(); if (!in_array(user()['role'], $roles, true)) { http_response_code(403); exit('Access denied.'); } }
function audit(PDO $pdo,string $action,?string $entity=null,?int $entityId=null,?string $details=null): void { $stmt=$pdo->prepare('INSERT INTO audit_logs(user_id,action,entity,entity_id,details,ip_address) VALUES(?,?,?,?,?,?)'); $stmt->execute([user()['id']??null,$action,$entity,$entityId,$details,$_SERVER['REMOTE_ADDR']??null]); }
function grade(float $total): array { if ($total >= 75) return ['A','Excellent']; if ($total >= 65) return ['B','Very Good']; if ($total >= 55) return ['C','Good']; if ($total >= 45) return ['D','Pass']; if ($total >= 40) return ['E','Fair']; return ['F','Fail']; }
function setting(PDO $pdo,string $key): string { static $s=null; if($s===null) $s=$pdo->query('SELECT * FROM settings LIMIT 1')->fetch() ?: []; return (string)($s[$key]??''); }
function generate_temp_password(int $length=12): string { $alphabet='ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789!@#$%'; $out=''; for($i=0;$i<$length;$i++) $out.=$alphabet[random_int(0,strlen($alphabet)-1)]; return $out; }
function next_registration_number(PDO $pdo,string $type): string {
    $year=(int)date('Y'); $key=$type.':'.$year; $code=preg_replace('/[^A-Z0-9]/','',strtoupper(setting($pdo,'school_code'))) ?: 'SCH'; $prefix=$type==='student'?'STD':'STF';
    $pdo->prepare('INSERT IGNORE INTO registration_sequences(sequence_key,last_number) VALUES(?,0)')->execute([$key]);
    $st=$pdo->prepare('SELECT last_number FROM registration_sequences WHERE sequence_key=? FOR UPDATE'); $st->execute([$key]); $n=((int)$st->fetchColumn())+1;
    $pdo->prepare('UPDATE registration_sequences SET last_number=? WHERE sequence_key=?')->execute([$n,$key]);
    return $code.'/'.$prefix.'/'.$year.'/'.str_pad((string)$n,4,'0',STR_PAD_LEFT);
}
function enqueue_notification(PDO $pdo,int $userId,string $channel,string $recipient,string $body,?string $subject=null): void {
    if (!in_array($channel,['email','sms','whatsapp'],true) || trim($recipient)==='') return;
    $st=$pdo->prepare('INSERT INTO notification_queue(user_id,channel,recipient,subject,body) VALUES(?,?,?,?,?)'); $st->execute([$userId,$channel,trim($recipient),$subject,$body]);
}
function notify_user(PDO $pdo,int $userId,string $subject,string $body): void {
    $st=$pdo->prepare('SELECT id,email,phone FROM users WHERE id=?'); $st->execute([$userId]); $u=$st->fetch(); if(!$u) return;
    if ((int)setting($pdo,'email_enabled')===1 && !empty($u['email'])) enqueue_notification($pdo,$userId,'email',$u['email'],$body,$subject);
    if ((int)setting($pdo,'sms_enabled')===1 && !empty($u['phone'])) enqueue_notification($pdo,$userId,'sms',$u['phone'],strip_tags($body),$subject);
    if ((int)setting($pdo,'whatsapp_enabled')===1 && !empty($u['phone'])) enqueue_notification($pdo,$userId,'whatsapp',$u['phone'],strip_tags($body),$subject);
}
function force_password_change(): void { if (user() && !empty(user()['must_change_password']) && basename($_SERVER['PHP_SELF'])!=='account.php' && basename($_SERVER['PHP_SELF'])!=='logout.php') redirect(APP_BASE_URL.'/account.php?first=1'); }
function user_has_teacher_class(PDO $pdo,int $teacherId,int $classId): bool { $st=$pdo->prepare('SELECT 1 FROM teacher_classes WHERE teacher_id=? AND class_id=?'); $st->execute([$teacherId,$classId]); return (bool)$st->fetchColumn(); }
function user_has_teacher_subject(PDO $pdo,int $teacherId,int $subjectId): bool { $st=$pdo->prepare('SELECT 1 FROM teacher_subjects WHERE teacher_id=? AND subject_id=?'); $st->execute([$teacherId,$subjectId]); return (bool)$st->fetchColumn(); }
