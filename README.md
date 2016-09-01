# nodemcu-socket-relay
For a first project with NodeMCU, turns a relay on and off with a TCP connection. Simulates the use of a hardware interlock.

## Usage
<pre>
fincham@amdahl:~$ telnet 192.168.1.1 2323
Trying 192.168.1.1...
Connected to 192.168.1.1.
Escape character is '^]'.

command unknown.
> status
soft armed: false. firing: false.
> firenow
unable to fire, not yet armed.
> softarm
soft arming in 10 seconds.
> status
soft armed: false. firing: false.
> status
soft armed: true. firing: false.
# firenow
firing for five seconds now!
# status
soft armed: true. firing: true.
# disarm
disarmed.
> status
soft armed: false. firing: false.
> 
</pre>
