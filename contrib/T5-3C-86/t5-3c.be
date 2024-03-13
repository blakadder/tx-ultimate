# Touch events handlers

def TXUltimate_Touch(value, trigger, msg)
    tasmota.cmd('Buzzer')
end

def TXUltimate_Short(value, trigger, msg)
    #print("message:")
    #print(msg)
    var Channel = msg['TXUltimate']['Channel']
    var ind
    if Channel <= 3
        ind = 0
        #tasmota.cmd('Power1 2')
        tasmota.set_power(ind, ! tasmota.get_power(ind))
    elif Channel >3 && Channel < 8
        ind = 1
        #tasmota.cmd('Power2 2')
        tasmota.set_power(ind, ! tasmota.get_power(ind))
    else
        ind = 2
        #tasmota.cmd('Power3 2')
        tasmota.set_power(ind, ! tasmota.get_power(ind))
    end
end

def TXUltimate_Swipe(value, trigger, msg)
    #print("message:")
    #print(msg)
    var Action = msg['TXUltimate']['Action']
    var targetstate
    if Action == 'Swipe right'
        targetstate = '1'
        var From = msg['TXUltimate']['From']
        var To = msg['TXUltimate']['To']
        # Fix: Power0 manage all channels include backlight
        tasmota.cmd('Power0 1')
    elif  Action == 'Swipe left'
        targetstate = '0'
        var From = msg['TXUltimate']['From']
        var To = msg['TXUltimate']['To']
        # Fix: Power0 manage all channels include backlight
        tasmota.cmd('Power0 0')
    end
end

tasmota.remove_rule("TXUltimate#Action=Touch", "Touch")
tasmota.add_rule("TXUltimate#Action=Touch", TXUltimate_Touch, "TXUltimate_Touch")

tasmota.remove_rule("TXUltimate#Action=Short", "TXUltimate_Short")
tasmota.add_rule("TXUltimate#Action=Short", TXUltimate_Short, "TXUltimate_Short")

tasmota.remove_rule("TXUltimate#Action=Swipe right", "TXUltimate_Swipe_right")
tasmota.add_rule("TXUltimate#Action=Swipe right", TXUltimate_Swipe, "TXUltimate_Swipe_right")
tasmota.remove_rule("TXUltimate#Action=Swipe left", "TXUltimate_Swipe_left")
tasmota.add_rule("TXUltimate#Action=Swipe left", TXUltimate_Swipe, "TXUltimate_Swipe_left")

