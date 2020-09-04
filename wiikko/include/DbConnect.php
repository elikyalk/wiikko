<?php

class DbConnect {

	private $conn;

	function __construct() {

	}

	function connect() {
		include_once dirname(__FILE__) . '/Config.php';
		$this->conn = new mysqli(DB_HOST, DB_USERNAME, DB_PASSWORD, DB_NAME);
		if (mysqli_connect_errno()) {
			echo "Impossible de se connecter à MySQL: " . mysqli_connect_error();
			die();
		}
        $this->conn->set_charset("utf8");
		return $this->conn;
	}

}