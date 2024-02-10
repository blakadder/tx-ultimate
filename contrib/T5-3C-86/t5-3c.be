def TXUltimate_Short(value, trigger, msg)
    print("message:")
    print(msg)
    var Channel = msg['TXUltimate']['Channel']
    if Channel <= 3
        tasmota.cmd('Power1 2')
    elif Channel >3 && Channel < 8
        tasmota.cmd('Power2 2')
    else
        tasmota.cmd('Power3 2')
    end
    tasmota.cmd('Buzzer 1,2')
end

def TXUltimate_Action(value, trigger, msg)
    print("message:")
    print(msg)
    var Action = msg['TXUltimate']['Action']
    if Action == 'Swipe right'
        tasmota.cmd('Power1 1')
        tasmota.cmd('Power2 1')
        tasmota.cmd('Power3 1')
        tasmota.cmd('Buzzer 1,2')
    elif  Action == 'Swipe left'
        tasmota.cmd('Power1 0')
        tasmota.cmd('Power2 0')
        tasmota.cmd('Power3 0')
        tasmota.cmd('Buzzer 1,2')
    end
end

tasmota.remove_rule("TXUltimate#Action=Short", "TXUltimate_Short")
tasmota.add_rule("TXUltimate#Action=Short", TXUltimate_Short, "TXUltimate_Short")

tasmota.remove_rule("TXUltimate#Action", "TXUltimate_Action")
tasmota.add_rule("TXUltimate#Action", TXUltimate_Action, "TXUltimate_Action")

