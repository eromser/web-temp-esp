# web-temp-esp

### Package Description

ESP8266 based thermometer with Web integration

### Supported platforms
- ESP8266 nodemcu build 1.5.4 and 2.1
- DHT22 sensor
- SSD1306 screen
- HC-05 Bluetooth module

### Detailed features list
- Measure temperature and humidity and show on a screen if button is pressed
- Report measured results to a web server (need WiFi connection and Internet in case receiving server is not in the local network)
- Provides a measured results page which is accessible directly from the ESP
- Syncronize time with an SNTP server (requires Internet enabled WiFi connection) 

### How to install

#### Wiring

If using a breadboard and want to replicate default setup just connect:

1 <i>DHT22 sensor</i>
 
  - Vin to any 3,4V pin of the ESP
  
  - GND to any 3,4V pin of the ESP
  
  - Signaling pin to PIN 3
	
2 <i>SSD1306 screen</i>
 
  - Vin to any 3,4V pin of the ESP
  
  - GND to any GND pin of the ESP
  
  - SDA to PIN 2 of the ESP
  
  - SCL to PIN 1 of the ESP

3 <i>Button</i>
 
  - First pin of the button to PIN 3 of the ESP
  
  - Second pin to any GND pin of the ESP
	
4 <i>Bluetooth module (I'm using ZS-040 which is claimed to be same as HC-05). You may also want to change default Bluetooth device name and pin code</i>

  - Vin to any 3,4V pin of the ESP
  
  - GND to any GND pin of the ESP
  
  - TX to RX of the ESP
  
  - RX to TX of the ESP

#### Change ESP8266 code settings

- Rename the `settings-template.lua` file to `settings.lua` 

- Adjust settings to match your environment 

```lua
SSID="<SSID>"
WIFI_PASSWORD="<PASSWORD>"
DISP_SDA = 2 -- SD1306 SDA Pin
DISP_SCL = 1 -- SD1306 SCL Pin
BUTTON_PIN =  3  -- Button Pin
PIN = 4 --  DHT22 Sensor Data Pin, D4
NTP_SERVER = "pool.ntp.org"
REPORT_SERVER = "xxx.yyy"
HASH_SECRET="<Some secret string>"
```

#### Web server configuration

- Create database and import DB.sql

- Rename `db-template.php` to `db.php` and change DB connection details and credentials  

- Copy following files to the directory of a PHP enabled server:

``` 
	db.php
	getData2.php
	image.php
	Inconsolata-Regular.ttf
	index.php
	service.php
	view2.html
```

- If you are not placing web related files to a server root adjust `init.lua` line:

```
                sck:send("GET /service.php?" .. to_send .. " HTTP/1.0\r\n"
                
```

### Web links

https://github.com/javieryanez/nodemcu-modules/tree/master/dht22

http://nodemcu.com/index_en.html

http://www.beerandchips.net/2015/12/26/making-nodemcu-lua-esp8266-weather-station/

https://primalcortex.wordpress.com/2015/02/19/esp8266-logging-data-in-a-mysql-database/
