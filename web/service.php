<?php

  include 'db.php';

  $now = new DateTime("now",new DateTimeZone("Europe/Moscow"));
  parse_str( html_entity_decode( $_SERVER['QUERY_STRING']) , $out);

  if (  array_key_exists( 'heap' , $out ) 
	&& array_key_exists( 'temp' , $out )
	&& array_key_exists( 'humi' , $out )
	&& array_key_exists( 'chipid' , $out )
	&& array_key_exists( 'pin' , $out )
     ) {

  $datenow = $now->format('Y-m-d H:i:s');
  $heap  = $out['heap'];
  $temp  = $out['temp'];
  $chipid  = $out['chipid'];
  $humi  = $out['humi'];
  $pin  = $out['pin'];

  if (!is_numeric($heap) || !is_numeric($temp) || !is_numeric($humi) || !is_numeric($chipid) || !is_numeric($pin)) {
    die("Wrong data" );
  }

  // Create connection
  $conn = new mysqli($servername, $username, $password, $dbname);
  // Check connection
  if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
  }

  $sql = "INSERT INTO DataTable ( logdate, heap, temperature, humidity, chipid, pin) "
			 ."VALUES ( '$datenow' , $heap, $temp, $humi, $chipid, $pin)";
			 
  if ($conn->query($sql) === TRUE) {
    echo "New record created successfully";
  } else {
    echo "Error: " . $sql . "<br>" . $conn->error;
  }

  $conn->close();
}
/**
$_POST = json_decode(file_get_contents('php://input'), true);
var_dump ($_POST);
**/

?>