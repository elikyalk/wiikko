<?php

require_once '../include/User.php';
require_once '../include/PassHash.php';
require_once '../include/Message.php';
require_once '../include/Notification.php';
require_once '../include/General.php';
require '.././libs/Slim/Slim.php';

\Slim\Slim::registerAutoloader();

$app = new \Slim\Slim();

$user = NULL;
$connection = NULL;
$firebaseServerKey = 'AAAA7pnajzQ:APA91bHBjB-v_1qwM9a0-_93OsV4g2v7zbeE1T5zggFkrbxNi4LGHQHyWgU2KTgorZAitCx4GcqEXGf0W98Qfj7lJ1t0qu7HaTmAQNxiAifYjw8rQLdHKzCRS1EtOBj9n-dGrMdpcbAS';

function getDatabase()
{
    global $connection;
    if ($connection == NULL) {
        require_once '../include/DbConnect.php';
        $db = new DbConnect();
        $connection = $db->connect();
    }
}

function authenticate($auth_code)
{
    $app = \Slim\Slim::getInstance();
    $response = array();
    getDatabase();
    global $connection;
    $obj = new User($connection);
    $obj->findAuthCode($auth_code);
    if ($obj->id > 0) {
        global $user;
        $user = $obj;
    } else {
        $response["error"] = true;
        $response["errorCode"] = "1111";
        $response["errorMessage"] = "Accès Refusé.\nCode d'authentification invalide.";
        echoRespnse(401, $response);
        $app->stop();
    }
}

//OK
$app->get('/login', function () use ($app) {
    verifyRequiredParams(array('username', 'password'));
    $request_params = $_REQUEST;
    $phone = $request_params['username'];
    $password = $request_params['password'];
    getDatabase();
    global $connection;
    $obj = new User($connection);
    $obj->login($phone, $password);
    $response = $obj->toArray();
    echoRespnse(200, $response);
});
//OK
$app->post('/user/fcmtoken/:auth_code', function ($auth_code) use ($app) {
    authenticate($auth_code);
    global $user;

    verifyRequiredParams2(array('token'));
    $request_params = $_REQUEST;
    $fcm_token = $request_params['token'];

    $user->fcmToken = $fcm_token;

    $user->modifier();
    if ($user->error) {
        $response['error'] = true;
        $response['errorCode'] = "INFTAI";
        $response['errorMessage'] = "Impossible d'ajouter le token de FCM !";
        $response['updated'] = false;
        echoRespnse(200, $response);
        $app->stop();
    }
    unOrSubscribeToTopic($fcm_token, "all_user");
    $response['error'] = false;
    $response['errorCode'] = "";
    $response['errorMessage'] = "";
    $response['updated'] = true;
    echoRespnse(200, $response);
});
//OK
$app->post('/user/create', function () use ($app) {
    verifyRequiredParams(array('userName', 'password'));
    getDatabase();
    global $connection;
    $body = json_decode($app->request()->getBody(), true);
    $response = array();

    $user = new User($connection);
    if ($user->isUserExists($body['userName'])) {
        $response['error'] = true;
        $response['errorCode'] = "4934";
        $response['errorMessage'] = "Cet utilisateur existe déjà. Choisissez un autre nom d'utilisateur et réessayez SVP.";
        echoRespnse(200, $response);
        $app->stop();
    }
    $user = User::fromArray($body, $connection);
    if ($user->error) {
        $response['error'] = true;
        $response['errorCode'] = $user->errorCode;
        $response['errorMessage'] = $user->errorMessage;
        echoRespnse(200, $response);
        $app->stop();
    }
    $user->ajouter();
    if ($user->error) {
        $response['error'] = true;
        $response['errorCode'] = $user->errorCode;
        $response['errorMessage'] = $user->errorMessage;
        echoRespnse(200, $response);
        $app->stop();
    }
    $response = $user->toArray();
    echoRespnse(200, $response);
});
//OK
$app->post('/message/send/:auth_code', function ($auth_code) use ($app) {
    authenticate($auth_code);
    global $user;
    getDatabase();
    global $connection;
    verifyRequiredParams(array('texte'));
    $body = json_decode($app->request()->getBody(), true);
    $msg = Message::fromArray($body, $connection);
    if ($msg->error) {
        $response['error'] = true;
        $response['errorCode'] = $msg->errorCode;
        $response['errorMessage'] = $msg->errorMessage;
        echoRespnse(200, $response);
        $app->stop();
    }
    $msg->idUserFrom = $user->id;
    $msg->ajouter();
    if ($msg->error) {
        $response['error'] = true;
        $response['errorCode'] = $msg->errorCode;
        $response['errorMessage'] = $msg->errorMessage;
        echoRespnse(200, $response);
        $app->stop();
    }
    firebaseNotificationToTopic($msg, "all_user", "message_$msg->id");
    $response = $msg->toArray();
    echoRespnse(200, $response);
});
//ok
$app->get('/message/list/:auth_code', function($authCode) use ($app) {
    authenticate($authCode);
    global $user;

    $offset = -1;
    if(isset($_REQUEST['offset']) && strlen($_REQUEST['offset'])>0) $lastId = (int) $_REQUEST['offset'];

    getDatabase();
    global $connection;
    $obj = new Message($connection);
    $listobj = $obj->findAll($offset);
    if($obj->error){
        $response['error'] = true;
        $response['errorCode'] = $obj->errorMessage;
        $response['errorMessage'] = $obj->errorMessage;
    }else{
        $response['error'] = false;
        $response['errorCode'] = "";
        $response['errorMessage'] = '';
        $response['liste'] = array();
        foreach($listobj as $obj1){
            $array = $obj1->toArray();
            array_push($response['liste'], $array);
        }
    }
    echoRespnse(200, $response);
});






function firebaseNotificationToTopic($message, $topic, $collapse_key) {
    $url = "https://fcm.googleapis.com/fcm/send";
    $topics = "/topics/$topic";
    global $firebaseServerKey;

    $data = $message->toArray();
    $data['click_action'] = "FLUTTER_NOTIFICATION_CLICK";

    //$notif = array('body' => $notification->texte, 'sound' => 'default', 'badge' => '1');
    //if($collapse_key !== "") $arrayToSend = array('to' => $topics, 'notification' => $notif, 'data' => $data, 'priority'=>'high', 'collapse_key' => $collapse_key);
    //else $arrayToSend = array('to' => $topics, 'notification' => $notif, 'data' => $data, 'priority'=>'high');
    if($collapse_key !== "") $arrayToSend = array('to' => $topics, 'data' => $data, 'priority'=>'high', 'collapse_key' => $collapse_key);
    else $arrayToSend = array('to' => $topics, 'data' => $data, 'priority'=>'high');

    $json = json_encode($arrayToSend);
    $headers = array();
    $headers[] = 'Content-Type: application/json';
    $headers[] = 'Authorization: key='. $firebaseServerKey;
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_CUSTOMREQUEST,"POST");
    curl_setopt($ch, CURLOPT_POSTFIELDS, $json);
    curl_setopt($ch, CURLOPT_HTTPHEADER,$headers);
    $response = curl_exec($ch);
    curl_close($ch);
}

function unOrSubscribeToTopic($token, $topic, $isAdd = true) {
    global $firebaseServerKey;
    $curlUrl = "https://iid.googleapis.com/iid/v1:batchAdd";
    if(!$isAdd) $curlUrl = "https://iid.googleapis.com/iid/v1:batchRemove";
    $mypush = array("to"=>"/topics/$topic", "registration_tokens"=>array($token));
    $myjson = json_encode($mypush);
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $curlUrl);
    curl_setopt($ch, CURLOPT_VERBOSE, 1);
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, FALSE);
    curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, FALSE);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
    curl_setopt($ch, CURLOPT_TIMEOUT, 60);
    curl_setopt($ch, CURLOPT_POST, True);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $myjson);
    curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type:application/json', "Authorization:key=$firebaseServerKey"));
    $response = curl_exec($ch);
    //return $response;
}

function verifyRequiredParams($required_fields)
{
    $error = false;
    $error_fields = "";
    $request_params = array();
    $request_params = $_REQUEST;
    if ($_SERVER['REQUEST_METHOD'] == 'PUT' || $_SERVER['REQUEST_METHOD'] == 'POST') {
        $app = \Slim\Slim::getInstance();
        $request_params = json_decode($app->request()->getBody(), true);

    }
    foreach ($required_fields as $field) {
        if (!isset($request_params[$field]) || strlen(trim($request_params[$field])) <= "") {
            $error = true;
            $error_fields .= $field . ', ';
        }
    }

    if ($error) {
        $response = array();
        $app = \Slim\Slim::getInstance();
        $response["error"] = true;
        $response["errorCode"] = "";
        $response["errorMessage"] = 'Champ(s) requis ' . substr($error_fields, 0, -2) . ' est (sont) manquant(s) ou vide(s)';
        echoRespnse(400, $response);
        $app->stop();
    }
}

function verifyRequiredParams2($required_fields)
{
    $error = false;
    $error_fields = "";
    $request_params = array();
    $request_params = $_REQUEST;
    foreach ($required_fields as $field) {
        if (!isset($request_params[$field]) || strlen(trim($request_params[$field])) <= "") {
            $error = true;
            $error_fields .= $field . ', ';
        }
    }

    if ($error) {
        $response = array();
        $app = \Slim\Slim::getInstance();
        $response["error"] = true;
        $response["errorCode"] = "";
        $response["errorMessage"] = 'Champ(s) requis ' . substr($error_fields, 0, -2) . ' est (sont) manquant(s) ou vide(s)';
        echoRespnse(400, $response);
        $app->stop();
    }
}

function echoRespnse($status_code, $response){
    ob_end_clean();

    $app = \Slim\Slim::getInstance();
    // Code de réponse HTTP
    $app->status($status_code);

    // la mise en réponse type de contenu en JSON
    $app->contentType('application/json');
    //echo utf8_encode(json_encode(utf8_string_array_encode($response)));
    //echo utf8_encode(json_encode($response));
    //print($response);
    //die();
    echo json_encode($response);
}

function utf8_string_array_encode(&$array){
    $func = function(&$value, &$key){
        if(is_string($value)){
            $value = utf8_encode($value);
        }
        if(is_string($key)){
            $key = utf8_encode($key);
        }
        if(is_array($value)){
            utf8_string_array_encode($value);
        }
    };
    array_walk($array, $func);
    return $array;
}

function utf8_string_array_decode(&$array){
    $func = function(&$value, &$key){
        if(is_string($value)){
            $value = utf8_decode($value);
        }
        if(is_string($key)){
            $key = utf8_decode($key);
        }
        if(is_array($value)){
            utf8_string_array_decode($value);
        }
    };
    array_walk($array, $func);
    return $array;
    //return $array;
}

$app->run();
