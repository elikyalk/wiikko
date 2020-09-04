<?php

class Message {
	private $conn;

	var $error = false;
	var $errorCode = "";
	var $errorMessage = "";
	var $id = -1;
	var $texte = "";
	var $idUserFrom = -1;
	var $creatingTime = "";

	function __construct($con) {
		$this->conn = $con;
	}

	public function toArray(){
		$rep = array();
		$rep['error'] = $this->error;
		$rep['errorCode'] = $this->errorCode;
		$rep['errorMessage'] = $this->errorMessage;
		$rep['id'] = $this->id;
		$rep['texte'] = $this->texte;
		$rep['idUserFrom'] = $this->idUserFrom;
        $userFrom = new User($this->conn);
        $userFrom = $userFrom->find($this->idUserFrom);
        if(!$userFrom->error) {
            $rep['username'] = $userFrom->userName;
        }
		$rep['creatingTime'] = $this->creatingTime;
		$rep['sendState'] = 0;
		return $rep;
	}

	public static function fromArray($array, $connection) {
	    $msg = new Message($connection);
		if(isset($array['texte']) && strlen(trim($array['texte'])) > 0) $msg->texte = $array['texte'];
		return $msg;
	}

	public function ajouter(){
		$sql = "INSERT INTO `wiikko_message`(`texte`, `id_user_from`) VALUES (?, ?)";
		$stmt = $this->conn->prepare($sql);
		if ($stmt === false) {
			$this->error = true;
			$this->errorCode = "1305";
			$this->errorMessage = "Erreur serveur\nUne erreur est survenue.";
			return $this;
		}
		$stmt->bind_param("si", $this->texte, $this->idUserFrom);
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
		$sql = "SELECT `texte`, `id_user_from`, `creating_time` FROM `wiikko_message` WHERE `id` = ?";
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
			$this->errorMessage = "Erreur serveur\nUne erreur est survenue lors de la récupération du message";
			return $this;
		}
		$stmt->bind_result($texte, $id_user_from, $time);
		$stmt->fetch();
		$stmt->close();
			if($id===NULL) {
			$this->error = true;
			$this->errorCode = "1302";
			$this->errorMessage = "Erreur serveur\nLe(la) message cherché(e) n'est pas trouvé(e)";
			return $this;
		}
		$this->error = false;
		$this->errorCode = "";
		$this->errorMessage = "";
		$this->id = $id;
		$this->texte = $texte;
		$this->idUserFrom = $id_user_from;
		$this->creatingTime = $time;
		return $this;
	}

	public function findAll($offset){
		$sql = "SELECT id FROM wiikko_message WHERE id > ? LIMIT ?, 20";
		$stmt = $this->conn->prepare($sql);
		$result = array();
		if ($stmt === false) {
			$this->error = true;
			$this->errorCode = "1304";
			$this->errorMessage = "Erreur serveur\nUne erreur est survenue.";
			return $this;
		}
        $stmt->bind_param("i", $offset);
		$stmt->execute();
		$stmt->store_result();
		$this->error = false;
		$this->errorCode = "";
		$this->errorMessage = "";
		while ($elt = General::fetchAssocStatement($stmt)) {
			$obj = new Message($this->conn);
			$obj = $obj->find($elt['id']);
			array_push($result, $obj);
		}
		$stmt->close();
		return $result;
	}

}