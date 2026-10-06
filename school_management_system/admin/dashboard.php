<?php $pageTitle='Dashboard'; require_once __DIR__.'/../includes/header.php';
$stats=[
'Students'=>$pdo->query("SELECT COUNT(*) FROM students WHERE status='active'")->fetchColumn(),
'Teachers'=>$pdo->query("SELECT COUNT(*) FROM teachers")->fetchColumn(),
'Parents'=>$pdo->query("SELECT COUNT(*) FROM parents")->fetchColumn(),
'Pending Admissions'=>$pdo->query("SELECT COUNT(*) FROM admissions WHERE status IN ('submitted','under_review')")->fetchColumn()
]; ?>
<h2>Administration</h2><div class="row g-3 mb-4"><?php foreach($stats as $k=>$v): ?><div class="col-md-3"><div class="card p-3"><div class="text-muted"><?=$k?></div><div class="display-6"><?=$v?></div></div></div><?php endforeach;?></div>
<div class="card p-4"><h5>Current term</h5><?php $t=$pdo->query("SELECT * FROM academic_terms WHERE is_current=1 LIMIT 1")->fetch(); ?><p><?=e($t['session_name']??'Not configured')?> — <?=e($t['term_name']??'')?></p><p class="mb-0">Use the menu to manage students, staff, results, attendance, admissions and parent communication.</p></div>
<?php require __DIR__.'/../includes/footer.php';