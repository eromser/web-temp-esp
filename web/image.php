<?php

include 'db.php';

// This is just an example of reading server side data and sending it to the client.
// It reads a json formatted text file and outputs it.

  $sqlq = "Select DATE_FORMAT(`logdate`, '%H:%i') AS time, temperature, humidity from DataTable order by id desc limit 1";

  // Create connection
  $conn = new mysqli($servername, $username, $password, $dbname);
  // Check connection
  if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
  }

  $result = mysqli_query( $conn , $sqlq );


$time = '';
$temp = '';

  if ( $result->num_rows  > 0 ) {
    $row = mysqli_fetch_array($result);
    $time = 'Measured at: '. $row['time'];
    $temp = 'Temperature: '. $row['temperature'].html_entity_decode(" &deg;C");
  }
  
  

// Instead you can query your database and parse into JSON etc etc
$conn->close();


// Create a blank image and add some text
//$font = 'cour.ttf';
$font = 'Inconsolata-Regular.ttf';
$im = imagecreatetruecolor(600, 400);
$text_color = imagecolorallocate($im, 233, 14, 91);
$white = imagecolorallocate($im, 255, 255, 255);
$grey = imagecolorallocate($im, 128, 128, 128);
$black = imagecolorallocate($im, 0, 0, 0);

imagefilledrectangle($im, 0, 0, 799, 599, $white);
//imagestring($im, 120, 5, 5,  $string, $text_color);
imagettftext($im, 40, 0, 20, 100, $black, $font, $time);
imagettftext($im, 40, 0, 20, 200, $black, $font, $temp);

// Set the content type header - in this case image/jpeg
header('Content-Type: image/jpeg');

// Output the image
imagejpeg($im);

// Free up memory
imagedestroy($im);
?>