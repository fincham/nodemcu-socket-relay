print "Starting up AP..."

local ap_config = {}
local ip_config = {}

ap_config.ssid = "ESP-"..node.chipid()
ap_config.pwd = "ESP-"..node.chipid()

ip_config.ip = "192.168.1.1"
ip_config.netmask = "255.255.255.0"
ip_config.gateway = "192.168.1.1"

wifi.setmode(wifi.SOFTAP)
print('SSID:', ap_config.ssid)
wifi.ap.config(ap_config)
wifi.ap.setip(ip_config)

print "AP configured."
print "Configuring other hardware..."
relay_pin = 1
gpio.write(relay_pin, gpio.LOW)
gpio.mode(relay_pin, gpio.OUTPUT)

print "Starting telnet server..."

soft_armed = false
firing = false

telnet_srv = net.createServer(net.TCP, 180)
telnet_srv:listen(2323, function(socket)
    local fifo = {}
    local fifo_drained = true
    local connected = false

    local function sender(c)
        if #fifo > 0 then
            c:send(table.remove(fifo, 1))
        else
            fifo_drained = true
        end
    end

    local function send(str)
        table.insert(fifo, str)
        if socket ~= nil and fifo_drained then
            fifo_drained = false
            sender(socket)
        end
    end

    socket:on("receive", function(connection, line) -- receives a single line from the client
        if string.sub(line, 1, 7) == "softarm" then
            send("soft arming in 10 seconds...\n")
            tmr.alarm(0, 10000, tmr.ALARM_SINGLE, function()
                soft_armed = true
            end)
        elseif string.sub(line, 1, 6) == "disarm" then
            soft_armed = false
            send("disarmed.\n")
        elseif string.sub(line, 1, 6) == "status" then
            if soft_armed then
                send("soft armed: true. ")
            else
                send("soft armed: false. ")
            end

            if firing then
                send("firing: true.")
            else
                send("firing: false.")
            end

            send("\n")
        elseif string.sub(line, 1, 7) == "firenow" then
            if soft_armed then
                send("firing for five seconds now!\n")
                firing = true
                tmr.alarm(1, 5000, tmr.ALARM_SINGLE, function()
                    gpio.write(relay_pin, gpio.LOW)
                    firing = false
                end)
                gpio.write(relay_pin, gpio.HIGH)
            else
                send("unable to fire, not yet armed.\n")
            end
        else
            send("command unknown.\n")
        end

        if soft_armed then
            send("# ")
        else
            send("> ")
        end
    end)

    socket:on("sent", sender)
end)
