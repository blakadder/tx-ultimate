# Touch events handlers

def get_leds_for_channel(ch)
    if ch <= 2
        return [13,21]
    elif ch >= 3 && ch <= 5
        return [11,23]
    elif ch >= 6 && ch <= 8
        return [9,25]
    else
        return [7,27]
    end
end

def get_leds_for_power(power)
    if power == 0
        return [13,21]
    elif power == 1
        return [11,23]
    elif power == 2
        return [9,25]
    else
        return [7,27]
    end
end

var eventtopic = "stat/lrms01"
var led_state = []
for i:0..27
    led_state.push('#000000')
end

def TXUltimate_Touch(value, trigger, msg)
    tasmota.cmd('Buzzer')
end

def TXUltimate_Led(leds, state)
    import string
    var color
    print("Set LED", leds, "to", state)
    if state == 'ON'
        color = '#14f240'
    elif state == 'OFF'
        color = '#ef3716'
    else
        color = state
    end
    

    for i:0..size(leds)-1
        led_state[leds[i]-1] = color
    end
    for i:0..2
        tasmota.cmd("Color #F0F0F0")
        tasmota.cmd("Color #000000")
    end
    for i:0..size(led_state)-1
        tasmota.cmd(string.format("Led%d %s", i+1, led_state[i]))
    end
end

def TXUltimate_Short(value, trigger, msg)
    #print("message:")
    #print(msg)
    import mqtt
    var Channel = msg['TXUltimate']['Channel']
    var ind
    var leds = []
    if Channel <= 2
        ind = 0
        leds = [13,21]
    elif Channel >= 3 && Channel <= 5
        ind = 1
        leds = [11,23]
    elif Channel >= 6 && Channel <= 8
        ind = 2
        leds = [9,25]
    else
        ind = 3
        leds = [7,27]
    end
    tasmota.set_power(ind, ! tasmota.get_power(ind))
    if tasmota.get_power(ind)
        TXUltimate_Led(leds, 'ON')
    else
        TXUltimate_Led(leds, 'OFF')
    end
    mqtt.publish(eventtopic .. "/Short", str(ind+1), false)
end

def TXUltimate_Long(value, trigger, msg)
    import mqtt
    var Channel = msg['TXUltimate']['Channel']
    var ind
    if Channel <= 2
        ind = 0
    elif Channel >= 3 && Channel <= 5
        ind = 1
    elif Channel >= 6 && Channel <= 8
        ind = 2
    else
        ind = 3
    end
    mqtt.publish(eventtopic .. "/Long", str(ind+1), false)
end

def TXUltimate_Swipe(value, trigger, msg)
    #print("message:")
    #print(msg)
    import mqtt
    var Action = msg['TXUltimate']['Action']
    var targetstate
    if Action == 'Swipe right'
        targetstate = '1'
        var From = msg['TXUltimate']['From']
        var To = msg['TXUltimate']['To']
        mqtt.publish(eventtopic .. "/EVENT", "SwipeRight", false)
        # NOTE: Power0 manage all channels include backlight
        tasmota.cmd('Power0 1')
    elif  Action == 'Swipe left'
        targetstate = '0'
        var From = msg['TXUltimate']['From']
        var To = msg['TXUltimate']['To']
        mqtt.publish(eventtopic .. "/EVENT", "SwipeLeft", false)
        # NOTE: Power0 manage all channels include backlight
        tasmota.cmd('Power0 0')
    end
end


def TXUltimate_Multi(value, trigger, msg)
    print("Handler Multi.")
    #print("message:")
    #print(msg)
    import mqtt
    mqtt.publish("stat/tasmota_E09620/EVENT", "Multi", false)
    # tasmota.publish_result("{'Action': 'Multi'}", "EVENT")
end


# Set initial state of leds
var power_state = [tasmota.get_power(0), tasmota.get_power(1), tasmota.get_power(2), tasmota.get_power(3), tasmota.get_power(4)]
for i:0..size(power_state)-1
    if power_state[i]
        var leds = get_leds_for_power(i)
        TXUltimate_Led(leds, 'ON')
    else
        var leds = get_leds_for_power(i)
        TXUltimate_Led(leds, 'OFF')
    end
end

#tasmota.remove_rule("TXUltimate#Action=Touch", "TXUltimate_Touch")
tasmota.add_rule("TXUltimate#Action=Touch", TXUltimate_Touch, "TXUltimate_Touch")

#tasmota.remove_rule("TXUltimate#Action=Short", "TXUltimate_Short")
tasmota.add_rule("TXUltimate#Action=Short", TXUltimate_Short, "TXUltimate_Short")

#tasmota.remove_rule("TXUltimate#Action=Long", "TXUltimate_Long")
tasmota.add_rule("TXUltimate#Action=Long", TXUltimate_Long, "TXUltimate_Long")

#tasmota.remove_rule("TXUltimate#Action=Swipe right", "TXUltimate_Swipe_right")
tasmota.add_rule("TXUltimate#Action=Swipe right", TXUltimate_Swipe, "TXUltimate_Swipe_right")
#tasmota.remove_rule("TXUltimate#Action=Swipe left", "TXUltimate_Swipe_left")
tasmota.add_rule("TXUltimate#Action=Swipe left", TXUltimate_Swipe, "TXUltimate_Swipe_left")

#tasmota.remove_rule("TXUltimate#Action=Multi", "TXUltimate_Multi")
tasmota.add_rule("TXUltimate#Action=Multi", TXUltimate_Multi, "TXUltimate_Multi")
#tasmota.cmd('Buzzer')
print("Events loaded.")
