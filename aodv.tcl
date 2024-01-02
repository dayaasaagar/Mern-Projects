#Set all the options

set val(chan)         Channel/WirelessChannel  ;# channel type
set val(prop)         Propagation/TwoRayGround ;# radio-propagation model
set val(ant)          Antenna/OmniAntenna      ;# Antenna type
set val(ll)           LL                       ;# Link layer type
set val(ifq)          Queue/DropTail/PriQueue  ;# Interface queue type
set val(ifqlen)       50                       ;# max packet in ifq
set val(netif)        Phy/WirelessPhy          ;# network interface type
set val(mac)          Mac/802_11               ;# MAC type
set val(rp)           AODV                     ;# routing protocol
set val(x)            800		       ;# X length
set val(y)            800		       ;# Y length
set val(finish)       10		       ;# Finish time
set val(nn)           10		       ;# number of mobilenodes
set ns_ [new Simulator]

set f [open out.tr w]
$ns_ trace-all $f 
set namtrace [open out.nam w]
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)
set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)
 
set god_ [create-god $val(nn)]
set chan_1 [new $val(chan)]

# CONFIGURE AND CREATE NODES

$ns_ node-config  -adhocRouting $val(rp) \
          -llType $val(ll) \
                 -macType $val(mac) \
                 -ifqType $val(ifq) \
                 -ifqLen $val(ifqlen) \
                 -antType $val(ant) \
                 -propType $val(prop) \
                 -phyType $val(netif) \
                 -topoInstance $topo \
                 -agentTrace ON \
                 -routerTrace ON \
                 -macTrace ON \
                 -movementTrace ON \
                 -channel $chan_1

for {set i 0} {$i < $val(nn) } { incr i } {
        set node_($i) [$ns_ node]
 $ns_ initial_node_pos $node_($i) 35
    }


proc finish {} {
    global ns_ namtrace filename
    $ns_ flush-trace
    close $namtrace  
    exec nam out.nam &
    exit 0
}

source mob
$ns_ at 0.0 "$node_(1) color blue"
$node_(1) color "blue"
$ns_ at 0.0 "$node_(2) color orange"
$node_(2) color "blue"

set udp_(0) [new Agent/UDP]
$ns_ attach-agent $node_(1) $udp_(0)
set null_(0) [new Agent/Null]
$ns_ attach-agent $node_(2) $null_(0)
set cbr_(0) [new Application/Traffic/CBR]
$cbr_(0) set packetSize_ 512
$cbr_(0) set interval_ 0.2
$cbr_(0) set random_ 1
$cbr_(0) set maxpkts_ 300
$cbr_(0) attach-agent $udp_(0)
$ns_ connect $udp_(0) $null_(0)
$ns_ at 0 "$cbr_(0) start"
$ns_ at 10 "$cbr_(0) stop"

$ns_ at $val(finish) "finish"
puts "Start of simulation..."
$ns_ run
