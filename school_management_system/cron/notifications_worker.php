<?php
// Run from CLI only. Configure provider credentials through environment variables where possible.
if(PHP_SAPI!=='cli'){http_response_code(403);exit('CLI only.');}
require_once __DIR__.'/../config.php'; require_once __DIR__.'/../includes/functions.php';
function deliver_notification(array $n,array $settings): array {
    if($n['channel']==='email'){$from=$settings['email_from']?:'no-reply@localhost';$headers="From: ".$from."\r\nContent-Type: text/plain; charset=UTF-8\r\n";$ok=mail($n['recipient'],$n['subject']?:'School notification',$n['body'],$headers);return [$ok,$ok?'mail() accepted the message':'mail() failed'];}
    $endpoint=$n['channel']==='sms'?$settings['sms_endpoint']:$settings['whatsapp_endpoint'];$token=$n['channel']==='sms'?$settings['sms_api_key']:$settings['whatsapp_token'];if(!$endpoint||!$token)return [false,'Provider endpoint/token not configured.'];if(!function_exists('curl_init'))return [false,'PHP cURL extension is required for SMS/WhatsApp delivery.'];
    if($n['channel']==='whatsapp'){$payload=['messaging_product'=>'whatsapp','to'=>$n['recipient'],'type'=>'text','text'=>['body'=>$n['body']]];$headers=['Authorization: Bearer '.$token,'Content-Type: application/json'];}else{$payload=['to'=>$n['recipient'],'message'=>$n['body'],'sender_id'=>$settings['sms_sender_id']];$headers=['Authorization: Bearer '.$token,'Content-Type: application/json'];}
    $ch=curl_init($endpoint);curl_setopt_array($ch,[CURLOPT_POST=>true,CURLOPT_POSTFIELDS=>json_encode($payload),CURLOPT_HTTPHEADER=>$headers,CURLOPT_RETURNTRANSFER=>true,CURLOPT_TIMEOUT=>20]);$response=curl_exec($ch);$code=(int)curl_getinfo($ch,CURLINFO_HTTP_CODE);$err=curl_error($ch);curl_close($ch);return [$code>=200&&$code<300,$err?:('HTTP '.$code.' '.$response)];
}
$settings=$pdo->query('SELECT * FROM settings WHERE id=1')->fetch();
for($i=0;$i<50;$i++){
 $pdo->beginTransaction();$st=$pdo->query("SELECT * FROM notification_queue WHERE status='queued' AND available_at<=NOW() ORDER BY id LIMIT 1 FOR UPDATE");$n=$st->fetch();if(!$n){$pdo->commit();break;}$pdo->prepare("UPDATE notification_queue SET status='processing',locked_at=NOW(),attempts=attempts+1 WHERE id=?")->execute([$n['id']]);$pdo->commit();
 [$ok,$response]=deliver_notification($n,$settings);if($ok){$pdo->prepare("UPDATE notification_queue SET status='sent',sent_at=NOW(),last_error=NULL WHERE id=?")->execute([$n['id']]);$pdo->prepare("INSERT INTO notification_logs(queue_id,channel,recipient,status,provider_response) VALUES(?,?,?,?,?)")->execute([$n['id'],$n['channel'],$n['recipient'],'sent',$response]);}else{$attempts=(int)$n['attempts']+1;$status=$attempts>=5?'failed':'queued';$delay=min(3600,60*$attempts);$pdo->prepare("UPDATE notification_queue SET status=?,available_at=DATE_ADD(NOW(),INTERVAL ? SECOND),last_error=? WHERE id=?")->execute([$status,$delay,$response,$n['id']]);$pdo->prepare("INSERT INTO notification_logs(queue_id,channel,recipient,status,provider_response) VALUES(?,?,?,?,?)")->execute([$n['id'],$n['channel'],$n['recipient'],'failed',$response]);}
}
echo "Notification worker completed.\n";
