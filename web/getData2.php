<?php 

include 'db.php';

// This is just an example of reading server side data and sending it to the client.
// It reads a json formatted text file and outputs it.

  $sqlq = "SELECT DATE_FORMAT(`logdate`, '%H:%i') AS time, temperature, humidity
		FROM  `DataTable` 
		WHERE DATE( logdate ) = CURDATE( )   order by id desc limit 100";

  // Create connection
  $conn = new mysqli($servername, $username, $password, $dbname);
  // Check connection
  if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
  }

  mysqli_query( $conn , "SET timezone = '+3:00'" );
  $result = mysqli_query( $conn , $sqlq );


$string = '{
  "cols": [
        {"id":"","label":"Log Time","pattern":"","type":"string"},
        {"id":"","label":"Temperature","pattern":"","type":"number"},
        {"id":"","label":"Humidity","pattern":"","type":"number"}
      ],
  "rows": [';

  if ( $result->num_rows  > 0 ) {
    while($row = mysqli_fetch_array($result)) {
    	$string .= '{"c":[{"v":"'. $row['time'] .'","f":null},{"v":'. $row['temperature'] .',"f":null},{"v":'. $row['humidity'] .',"f":null}]},';
    }
  }
  
$string .=']}';

echo $string;

// Instead you can query your database and parse into JSON etc etc
$conn->close();

?>