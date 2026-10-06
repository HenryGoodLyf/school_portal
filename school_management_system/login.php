<?php
require_once __DIR__.'/config.php'; require_once __DIR__.'/includes/functions.php';
if(user()) redirect(user()['role'].'/dashboard.php');
$error='';
if($_SERVER['REQUEST_METHOD']==='POST'){
    verify_csrf();
    $username=trim($_POST['username']??'');
    $stmt=$pdo->prepare("SELECT * FROM users WHERE username=? LIMIT 1"); $stmt->execute([$username]); $u=$stmt->fetch();
    $blocked=$u && (($u['status']!=='active') || (!empty($u['locked_until']) && strtotime($u['locked_until'])>time()));
    if($u && !$blocked && password_verify($_POST['password']??'', $u['password_hash'])){
        $pdo->prepare("UPDATE users SET failed_login_attempts=0,locked_until=NULL,last_login_at=NOW() WHERE id=?")->execute([$u['id']]);
        session_regenerate_id(true); $_SESSION['user']=$u; $_SESSION['user']['password_hash']=null; audit($pdo,'login','users',(int)$u['id']);
        redirect($u['role'].'/dashboard.php');
    }
    if($u && $u['status']==='active'){
        $attempts=(int)$u['failed_login_attempts']+1; $lock=$attempts>=5?date('Y-m-d H:i:s',time()+900):null;
        $pdo->prepare("UPDATE users SET failed_login_attempts=?,locked_until=? WHERE id=?")->execute([$attempts,$lock,$u['id']]);
    }
    $error='Invalid username or password.';
}
?><!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title><?=e(setting($pdo,'school_name'))?> — Sign in</title><link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"></head>
<body class="bg-light"><div class="container py-5"><div class="row justify-content-center"><div class="col-md-5"><div class="card shadow-sm"><div class="card-body p-4">
<?php if(setting($pdo,'logo')): ?><img src="<?=e(APP_BASE_URL.'/'.setting($pdo,'logo'))?>" alt="School logo" style="max-height:80px;max-width:180px" class="mb-3"><?php endif; ?><h3 class="mb-4"><?=e(setting($pdo,'school_name'))?> Portal</h3>
<?php if($error): ?><div class="alert alert-danger"><?=e($error)?></div><?php endif; ?><form method="post" autocomplete="off"><input type="hidden" name="csrf" value="<?=e(csrf_token())?>"><div class="mb-3"><label class="form-label">Username</label><input class="form-control" name="username" required autofocus autocomplete="username"></div><div class="mb-3"><label class="form-label">Password</label><input class="form-control" type="password" name="password" required autocomplete="current-password"></div><button class="btn btn-primary w-100">Sign in</button></form></div></div><a class="d-block text-center mt-3" href="index.php">Back to school portal</a></div></div></div></body></html>
