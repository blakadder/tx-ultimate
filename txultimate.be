class TXUltimate : Driver
  static header = bytes('AA55') 

  var ser  # create serial port object
       
  # intialize the serial port, if unspecified Tx/Rx are GPIO 16/17
  def init(tx, rx)
    if !tx   tx = 19 end
    if !rx   rx = 22 end
    self.ser = serial(rx, tx, 115200, serial.SERIAL_8N1)
    tasmota.add_driver(self)
  end

  def split_55(b)
    var ret = []
    var s = size(b)   
    var i = s-2   # start from last-1
    while i > 0
      if b[i] == 0xAA && b[i+1] == 0x55           
        ret.push(b[i..s-1]) # push last msg to list
        b = b[(0..i-1)]   # write the rest back to b
      end
      i -= 1
    end
    ret.push(b)
    return ret
  end

  def crc16(data, poly)
    if !poly  poly = 0x1021 end
    # CRC-16/CCITT-FALSE HASHING ALGORITHM
    var crc = 0xFFFF
    for i:0..size(data)-1
      crc = crc ^ data[i] << 8
      for j:0..7
        if crc & 0x8000
          crc = (crc << 1) ^ poly
        else
          crc = crc << 1
        end
      end
    end
    return crc & 0xFFFF
  end

  def encode(payload)
    var msg_crc = self.crc16(bytes(payload)) # calc crc
    var b = bytes('AA55') # add header
    b += bytes(payload) # add payload
    b.add(msg_crc, -2)   # add calculated crc 2 bytes, big endian
    return b
  end

  
  # send a string payload (needs to be a valid json string)
  def send(payload)
    print("TXU: Sent =", payload)
    var payload_bin = self.encode(payload)
    self.ser.write(payload_bin)
    log("TXU: Sent = " + str(payload_bin), 2)
  end

  # read serial port
  def every_50ms()
    if self.ser.available() > 0
    var msg = self.ser.read()   # read bytes from serial as bytes
    import string
      if size(msg) > 0
        # print("TXU: Raw =", msg)
        if msg[0..1] == self.header
          var lst = self.split_55(msg)
          for i:0..size(lst)-1
            msg = lst[i]
            print(msg)
            var event = ""
            var params = ""
            if msg[3] == 0x02 # 02 signifies a touch event
                # print('Touch event')
                if msg[4] == 0x01 # data lenght 1 is a press
                    if   msg[5] < 0x0B 
                      event = "Short"
                      params = ',"Channel":' + str(msg[5])
                      print('Short press zone:', msg[5])
                    elif msg[5] == 0x0B 
                      event = "Multi"
                      print('Multi press')
                    elif msg[5] > 0x0B 
                      event = "Long"
                      params = ',"Channel":' + str(msg[5]-16)
                      print('Long press zone:', msg[5])         
                    end
                elif msg[4] == 0x02 # data length 3 is a release
                    event = "Touch"
                    params = ',"Channel":' + str(msg[6])
                    print('Touch event:', msg[5], 'pos:', msg[6])
                    if msg[5] != 0x00
                      event = "Dash"
                      params = ',"From":' + str(msg[6]) + ',"To":' + str(msg[5])
                      print('Mini swipe channel', msg[5], '->', msg[6])
                    end
                    elif msg[4] == 0x03 # data lenght 1 is a swipe
                    if msg[5] == 0x0C                     
                        event = "Swipe right"
                        params = ',"From":' + str(msg[6]) + ',"To":' + str(msg[7])
                        print('Swipe left-right', msg[6], '->', msg[7])
                    elif msg[5] == 0x0D 
                        event = "Swipe left"
                        params = ',"From":' + str(msg[6]) + ',"To":' + str(msg[7])
                        print('Swipe right-left', msg[6], '->', msg[7])
                    end
              end
            var jm = string.format("{\"TXUltimate\":{\"Action\":\"%s\"%s}}",event,params)
            tasmota.publish_result(jm, "RESULT") 
            end
          end
        end
      end      
    end
  end
end

txu=TXUltimate()
