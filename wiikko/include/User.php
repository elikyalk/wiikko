<?php

class User {
	private $conn;

	var $error = false;
	var $errorCode = "";
	var $errorMessage = "";
	var $id = -1;
	var $userName = "";
	var $authCode = "";
	var $urlPhoto = "";
	var $urlThumbnail = "";
	var $creatingTime = "";
	var $fcmToken = "";
	var $password = "";

	function __construct($con) {
		$this->conn = $con;
	}

    public function setPassword($value) {
        $this->password = PassHash::hash($value);
    }

    public function toArray(){
		$rep = array();
		$rep['error'] = $this->error;
		$rep['errorCode'] = $this->errorCode;
		$rep['errorMessage'] = $this->errorMessage;
		$rep['id'] = $this->id;
		$rep['userName'] = $this->userName;
		$rep['authCode'] = $this->authCode;
		$rep['urlPhoto'] = $this->urlPhoto;
		$rep['urlThumbnail'] = $this->urlThumbnail;
		$rep['creatingTime'] = $this->creatingTime;
		return $rep;
	}

    public static function fromArray($array, $connexion) {
        $user = new User($connexion);
        if(isset($array['userName']) && strlen(trim($array['userName'])) > 0) {
            if(strlen(trim($array['userName'])) < 5) {
                $user->error = true;
                $user->errorCode = "USIDFN";
                $user->errorMessage = "Votre pseudo doit avoir au moins 5 caractères et ne pas dépasser 30 caractères !";
                return $user;
            }
            $user->userName = $array['userName'];
        }
        if(isset($array['password']) && strlen(trim($array['password'])) > 0) {
            if(!General::correctPassword($array['password'])) {
                $user->error = true;
                $user->errorCode = "USIDPA";
                $user->errorMessage = "Le mot de passe que vous avez saisi ne respecte pas nos critères de mot de passe !\nLe mot de passe doit avoir au moins 8 caractères et ne doit pas inclure des espaces.";
                return $user;
            }
            $user->setPassword($array['password']);
        }
        return $user;
    }

	public function ajouter(){
		$sql = "INSERT INTO `wiikko_user`(`username`, `auth_code`, `fcm_token`, `password`) VALUES (?, ?, ?, ?)";
		$stmt = $this->conn->prepare($sql);
		if ($stmt === false) {
			$this->error = true;
			$this->errorCode = "1305";
			$this->errorMessage = "Erreur serveur\nUne erreur est survenue.";
			return $this;
		}
		$this->authCode = md5(uniqid(rand(), true));
        $stmt->bind_param("ssss", $this->userName, $this->authCode, $this->fcmToken, $this->password);
		$stmt->execute();
		$res_id = $this->conn->insert_id;
		$stmt->close();
		if ($res_id<=0) {
			$this->error = true;
			$this->errorCode = "1306";
			$this->errorMessage = "Erreur serveur\nUne erreur est survenue.";
			return $this;
		}
        $this->find($res_id);
	}

    public function find($id){
        $sql = 'SELECT `username`, `auth_code`, `url_photo`, `url_thumb`, `creating_time`, `fcm_token`, `password` FROM `wiikko_user` WHERE `id` = ?';
        $stmt = $this->conn->prepare($sql);
        if ($stmt === false) {
            $this->error = true;
            $this->errorCode = "1301";
            $this->errorMessage = "Erreur serveur\nUne erreur est survenue.";
            return $this;
        }
        $stmt->bind_param("i", $id);
        if (!$stmt->execute()) {
            $this->error = true;
            $this->errorCode = "1303";
            $this->errorMessage = "Erreur serveur\nUne erreur est survenue lors de la récupération de l'utilisateur";
            return $this;
        }
        $stmt->bind_result($username, $auth_code, $url_photo, $url_thumb, $creating_time, $fcm_token, $password);
        $stmt->fetch();
        $stmt->close();
        if($id===NULL) {
            $this->error = true;
            $this->errorCode = "1302";
            $this->errorMessage = "Erreur serveur\nL'utilisateur cherché n'est pas trouvé.";
            return $this;
        }
        $this->id = $id;
        $this->userName = $username;
        $this->authCode = $auth_code;
        $this->urlPhoto = $url_photo;
        $this->urlThumbnail = $url_thumb;
        $this->creatingTime = $creating_time;
        $this->fcmToken = $fcm_token;
        $this->password = $password;
        return $this;
    }

    public function findAuthCode($ac){
        $sql = 'SELECT `id` FROM `wiikko_user` WHERE `auth_code` = ?';
        $stmt = $this->conn->prepare($sql);
        if ($stmt === false) {
            $this->error = true;
            $this->errorCode = "1301";
            $this->errorMessage = "Erreur serveur\nUne erreur est survenue.";
            return $this;
        }
        $stmt->bind_param("s", $ac);
        if (!$stmt->execute()) {
            $this->error = true;
            $this->errorCode = "1303";
            $this->errorMessage = "Erreur serveur\nUne erreur est survenue lors de la récupération de l'utilisateur";
            return $this;
        }
        $stmt->bind_result($id);
        $stmt->fetch();
        $stmt->close();
        if($id===NULL) {
            $this->error = true;
            $this->errorCode = "1302";
            $this->errorMessage = "Erreur serveur\nL'utilisateur cherché n'est pas trouvé.";
            return $this;
        }
        $this->find($id);
        return $this;
    }

    public function login($username, $pw){
        $sql = 'SELECT `id` FROM `wiikko_user` WHERE `username` = ?';
        $stmt = $this->conn->prepare($sql);
        if ($stmt === false) {
            $this->error = true;
            $this->errorCode = "1301";
            $this->errorMessage = "Erreur serveur\nUne erreur est survenue.";
            return $this;
        }
        $stmt->bind_param("s", $username);
        if (!$stmt->execute()) {
            $this->error = true;
            $this->errorCode = "1303";
            $this->errorMessage = 'Erreur serveur\nUne erreur est survenue lors du login.';
            return $this;
        }
        $stmt->bind_result($id);
        $stmt->fetch();
        $stmt->close();
        if($id===NULL) {
            $this->error = true;
            $this->errorCode = "1302";
            $this->errorMessage = "Le pseudo saisi est incorrect.";
            return $this;
        }
        $user = new User($this->conn);
        $user->find($id);
        if (!PassHash::check_password($user->password, $pw)) {
            $this->error = true;
            $this->errorCode = "1302";
            $this->errorMessage = "Le mot de passe saisi est incorrect.";
            return $this;
        }
        $this->find($id);
        return $this;
    }

    public function correctPassword($auth_code, $pw){
        $stmt = $this->conn->prepare("SELECT `password` FROM `wiikko_user` WHERE `auth_code` = ?");
        if ($stmt === false) {
            $this->error = true;
            $this->errorCode = "1301";
            $this->errorMessage = "Erreur serveur\nUne erreur est survenue.";
            return $this;
        }
        $stmt->bind_param("s", $auth_code);
        $stmt->execute();
        $stmt->bind_result($password);
        $stmt->store_result();
        if ($stmt->num_rows > 0) {
            $stmt->fetch();
            $stmt->close();
            if (PassHash::check_password($password, $pw)) {
                return TRUE;
            } else {
                return FALSE;
            }
        } else {
            $stmt->close();
            return FALSE;
        }
    }

    public function isUserExists($username){
        $sql = 'SELECT `id` FROM `wiikko_user` WHERE `username` = ?';
        $stmt = $this->conn->prepare($sql);
        if ($stmt === false) {
            $this->error = true;
            $this->errorCode = 1301;
            $this->errorMessage = "Erreur serveur\nUne erreur est survenue.";
            return true;
        }
        $stmt->bind_param("s", $username);
        if ($stmt->execute()) {
            $stmt->bind_result($id);
            $stmt->fetch();
            $stmt->close();
            if($id==NULL) return false;
        }
        return true;
    }

    public function modifier(){
        $sql = "UPDATE `wiikko_user` SET `username`=?, `password`=?, `fcm_token`=?, `url_photo`=?, `url_thumb`=? WHERE `id` = ?";
        $stmt = $this->conn->prepare($sql);
        if ($stmt === false) {
            $this->error = true;
            $this->errorCode = "1007";
            $this->errorMessage = "Erreur serveur\nUne erreur est survenue.";
            return $this;
        }
        $stmt->bind_param("sssssi", $this->userName, $this->password, $this->fcmToken, $this->urlPhoto, $this->urlThumbnail, $this->id);
        $stmt->execute();
        $num_affected_rows = $stmt->affected_rows;
        $stmt->close();
        if($num_affected_rows <= 0) {
            $this->error = true;
            $this->errorCode = "1008";
            $this->errorMessage = "Erreur serveur\nUne erreur est survenue.";
            return $this;
        }
        $this->error = false;
        $this->errorCode = "";
        $this->errorMessage = "";
    }

}