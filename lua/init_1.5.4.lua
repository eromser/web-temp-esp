dofile("settings.lua")

-- static IP setup from http://www.domoticz.com/wiki/ESP8266_WiFi_module


--INIT UART 38400
uart.setup(0, 38400, 8, uart.PARITY_NONE, uart.STOPBITS_1, 1)

print(	"==CONFIGURATION LOADED==\r\n" 
	.. "SSID: ".. SSID .."\r\n"
--	.. "WIFI_PASSWORD: ".. WIFI_PASSWORD .."\r\n"
	.. "BUTTON_PIN: ".. BUTTON_PIN .."\r\n"
	.. "DISP_SDA: ".. DISP_SDA .."\r\n"
	.. "DISP_SCL: ".. DISP_SCL .."\r\n"
	.. "PIN: ".. PIN .."\r\n"
	.. "NTP_SERVER: ".. NTP_SERVER .."\r\n"
	.. "REPORT_SERVER: ".. REPORT_SERVER .."\r\n"
	.. "HASH_SECRET: ".. HASH_SECRET .."\r\n"
	.. "==CONFIGURATION LOADED==\r\n" 
)


-- Init SD1396 display
function init_OLED(sda,scl) --Set up the u8glib lib
     sla = 0x3C
     i2c.setup(0, DISP_SDA, DISP_SCL, i2c.SLOW)
     disp = u8g.ssd1306_128x64_i2c(sla)
     disp:setFont(u8g.font_6x10)
     disp:setFontRefHeightExtendedText()
     disp:setDefaultForegroundColor()
     disp:setFontPosTop()
     disp:setScale2x2()
     disp:sleepOff()
     --disp:setRot180()           -- Rotate Display if needed
end

-- Display function
function write_OLED() -- Write Display
   disp:firstPage()
   xPos = 0
   repeat
     --disp:drawFrame(2,2,126,62)
      sec,usec = rtctime.get()
      sec = 3*60*60+sec
      tm = rtctime.epoch2cal(unpack{sec, usec})
    --print(string.format("%04d/%02d/%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"]))
     --disp:drawStr(16, 0,  string.format("%02d.%02d.%04d %02d:%02d", tm["day"], tm["mon"], tm["year"], tm["hour"], tm["min"]))
     disp:drawStr(18, -1,  string.format("%02d:%02d", tm["hour"], tm["min"]))
    if status == dht.OK then
       displayStr = t .. " C"
       cirXPos = xPos + (string.len(displayStr))*6 - 9
       disp:drawCircle(cirXPos, 16, 1)
    elseif status == dht.ERROR_CHECKSUM then
       displayStr = "CHKSUM"
    elseif status == dht.ERROR_TIMEOUT then
       displayStr = "TIMEOUT"
    end
     xPos = 32 - (string.len(displayStr)*6)/2
     disp:drawStr(xPos, 14,  string.format("%0s",displayStr))

     --disp:undoScale()
   until disp:nextPage() == false
   
end

function clear_OLED() -- Clear Display
   disp:firstPage()
   repeat
   until disp:nextPage() == false
end

-- Main loop
init_OLED(sda,scl)
clear_OLED()

status, t, h, temp_dec, humi_dec = dht.read(PIN)

--Button Handler
gpio.mode(BUTTON_PIN, gpio.INT, gpio.PULLUP)
gpio.trig(BUTTON_PIN, "down", function(level)
 -- Write screen on / off code
    tmr.delay(10)  
    disp:sleepOff()
    write_OLED(displayStr)

  tmr.alarm(4, 10000, tmr.ALARM_SINGLE, function()
    clear_OLED()
    disp:sleepOn()
   end)
 end)

wifi.setmode(wifi.STATION)
wifi.sta.config(ssid = SSID, pwd = WIFI_PASSWORD)
wifi.sta.connect( function()
    tmr.alarm(1, 1000, 1, function()
         if wifi.sta.getip() == nil then
            print("Connecting...")
         else
            tmr.stop(1)
            print("Connected, IP is "..wifi.sta.getip())
            print("ESP8266 WiFi mode is: " .. wifi.getmode())
            print("The module MAC address is: " .. wifi.ap.getmac())
        
    	sntp.sync(NTP_SERVER,
              function(sec,usec,server)
                sec,usec = rtctime.get()
                sec = 3*60*60+sec
                tm = rtctime.epoch2cal(unpack{sec, usec})
                print(string.format("%04d/%02d/%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"]))
              end,
              function()
    	    print('NTP sync failed!')
    	  end)
    end
)
-- Web Server START --
        srv=net.createServer(net.TCP, 4)
        print("Server created on " .. wifi.sta.getip())
        srv:listen(80,function(conn)
            conn:on("receive",function(conn,request)
                print(request)
                
                status, t, h, temp_dec, humi_dec = dht.read(PIN)
                
                if string.match(request, "machine") then
                    if status == dht.OK then 
                        conn:send("\"Temperature\": \""..t.."\", \"Humidity\": \""..h.."\"")
                    elseif status == dht.ERROR_CHECKSUM then
                        print( "DHT Checksum error." )
                    elseif status == dht.ERROR_TIMEOUT then
                        print( "DHT timed out." )
                    end 
   
                else
                  local response = {}

                  if nil == string.match(request, "/favicon.ico") then
                        response[#response + 1] = "HTTP/1.0 200 Ok\r\n\r\n"
                        response[#response + 1] = '<html>'
                        response[#response + 1] = '<title>On Deck</title></head>'
                        response[#response + 1] = '<body bgcolor=\"#ffffff\">'
                        response[#response + 1] = '<center>'

                    if status == dht.OK then 
                        response[#response + 1] = '<table bgcolor=\"#0000ff\" width=\"90%\" border=\"0\">'
                        response[#response + 1] = '<tr>'
                        response[#response + 1] = '  <td><font size=\"2\" face=\"arial, helvetica\" color=\"#ffffff\"><center>Temperature</center></font></td>'
                        response[#response + 1] = '</tr>'
                        response[#response + 1] = '<tr>'
                        response[#response + 1] = '  <td><font size=\"7\" face=\"arial, helvetica\" color=\"#ffffff\"><center>'..t..'&deg;C</center></font></td>'
                        response[#response + 1] = '</tr>'
                        
                        response[#response + 1] = '<tr>'
                        response[#response + 1] = '  <td><font size=\"2\" face=\"arial, helvetica\" color=\"#ffffff\"><center>Humidity</center></font></td>'
                        response[#response + 1] = '</tr>'
                        response[#response + 1] = '<tr>'
                        response[#response + 1] = '  <td><font size=\"5\" face=\"arial, helvetica\" color=\"#ffffff\"><center>'..h..'%</center></font></td>'
                        response[#response + 1] = '</tr>'
                        
                        response[#response + 1] = '</table>'
                    elseif status == dht.ERROR_CHECKSUM then
                        response[#response + 1] = '<font size=\"5\" face=\"arial, helvetica\" color=\"#ff0000\"><center>DHT Checksum error.</center></font>' 
                    elseif status == dht.ERROR_TIMEOUT then
                        response[#response + 1] = '<font size=\"5\" face=\"arial, helvetica\" color=\"#ff0000\"><center>DHT timed out.</center></font>'
                    end 
                        response[#response + 1] = '</center>'
                        response[#response + 1] = '</body></html>'
 
                  else
                    response = {"HTTP/1.0 404 Not found\r\n\r\n"}
                  end
                    -- sends and removes the first element from the 'response' table
                    local function send(sk)
                          if #response > 0
                            then sk:send(table.remove(response, 1))
                          else
                            sk:close()
                            response = nil
                          end
                    end
                    -- triggers the send() function again once the first chunk of data was sent
                    conn:on("sent", send)
                    
                    send(conn)
                end
            end)
        end)
--Web Server END --
        -- set up some DHT22 things from https://github.com/javieryanez/nodemcu-modules/tree/master/dht22

        chipserial = node.chipid()

        tmr.alarm(  2, 900000, tmr.ALARM_AUTO, function()         
        status, t, h, temp_dec, humi_dec = dht.read(PIN)
        if status == dht.OK then
            heap = node.heap()   
            to_send = "heap=" ..node.heap() .. "&temp=" .. t .. "&humi=" .. h .. "&chipid=" .. node.chipid() .. "&pin=" .. PIN
            sha_hash = crypto.toHex(crypto.hash("sha256", to_send .. HASH_SECRET))
            to_send = to_send .. "&hash=" .. sha_hash
            print(to_send .. "\r\n")
    
            conn=net.createConnection(net.TCP, false)
            conn:on("receive", function(conn, payload) print(payload) end )
            conn:connect(80,REPORT_SERVER)
            conn:on("connection", function(sck, c)
                sck:send("GET /service.php?" .. to_send .. " HTTP/1.0\r\n"
                    .. "Host: ".. REPORT_SERVER .. "\r\n"
                    .. "Connection: keep-alive\r\n"
                    .. "User-Agent: ESP8266/Sensor\r\n"
                    .. "Accept: */*\r\n\r\n")
                end) --[[]]
        
        elseif status == dht.ERROR_CHECKSUM then
            print( "DHT Checksum error." )
        elseif status == dht.ERROR_TIMEOUT then
            print( "DHT timed out." )
        end
        --conn.close()
        end)
   end
end)
