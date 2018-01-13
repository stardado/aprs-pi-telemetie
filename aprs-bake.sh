#!/bin/bash
# Hier bitte deine Zugangdaten und Statustexte zum APRS-IS eingeben.
call="DO7TC"
passcode="17401"
statustext="Verbunden via HAMNET - Telemetrie zeigt Systemstatus des RaspberryPi"
# Pfad wo das Script liegt:
PFAD="/home/pi/"
# IP oder Domain zum HAMNET APRS-IS Server:
hamnet="44.225.73.2"
# IP oder Domain zum Internet APES-IS Server:
internet="217.160.179.143"
# Adresse zum NOAA Server, der die Matar Daten hostet:
noaalink="http://tgftp.nws.noaa.gov/data/observations/metar/stations/"

# Beginn des Scriptes
#
# Script von Denis Apel - DO7TC - 2017-2018
#
# Ab hier nchts mehr eintragen
 echo "> APRS-Daten senden gestartet."
 echo "> Route wird gesucht."
telemetrie(){
zahl="$TEMP/zahl.txt"
if [ ! -f $zahl ]; then
    echo "Fehler: "$zahl" ist nicht vorhanden, wird nun angelegt."
    echo 100 > $zahl
fi
export TEMP="${XDG_RUNTIME_DIR:-/tmp}"
noaalink="http://tgftp.nws.noaa.gov/data/observations/metar/stations/"
wget -q "$noaalink"EDDB.TXT -O $TEMP/EDDB.txt
EDDB=$(cat $TEMP/EDDB.txt | grep EDDB)
wget -q "$noaalink"EDDT.TXT -O $TEMP/EDDT.txt
EDDB=$(cat $TEMP/EDDT.txt | grep EDDT)
wget -q "$noaalink"EDDP.TXT -O $TEMP/EDDP.txt
EDDB=$(cat $TEMP/EDDP.txt | grep EDDP)
wget -q "$noaalink"ETSH.TXT -O $TEMP/ETSH.txt
EDDB=$(cat $TEMP/ETSH.txt | grep ETSH)
echo "user $call pass $passcode
$call-10>APE001,WIDE1-1,TCPIP*:!5236.49N/01324.96EI Denis / http://www.do7tc.de / RaspberryPi TESTBETRIEB
$call-10>APE001,WIDE1-1,TCPIP*:>$statustext
$call-10>BEACON,TCPIP*:;DM0UB    *111111z5225.31NB01252.89E0DM0UB Bakensender 115m ue. NN, VFDB Z94 - http://z94.vfdb.org, Sendefrequenzen: 1296.850 MHz, 2320.850 MHz, 5
760.850 MHz, 10368.850 MHz
$call-10>BEACON,TCPIP*:;FW2600   *111111z5234.92N/01325.74EdFeuerwehr Pankow, Direktion Nord, Wache Nr. 2600
$call-10>BEACON,TCPIP*:;EDAZ/QXH *111111z5212.23N/01309.61E'Flugplatz Schoenhagen, Metar: $EDDB
$call-10>BEACON,TCPIP*:;EDBW     *111111z5237.98N/01346.02E'Flugplatz Werneuchen, Metar: $EDDB
$call-10>BEACON,TCPIP*:;EDAV     *111111z5249.63N/01341.61E'Flugplatz Eberswalde Finow, Tower: 119,050 Mhz, Metar: $EDDT
$call-10>BEACON,TCPIP*:;EDCE     *111111z5228.96N/01405.45E'Flugplatz Eggersdorf, Tower: 123,000 Mhz, Metar: $EDDB
$call-10>BEACON,TCPIP*:;EDAY/QPK *111111z5234.80N/01354.93E'Flugplatz Strausberg, Tower: 123.050 MHz, Metar: $EDDB
$call-10>BEACON,TCPIP*:;EDUZ     *111111z5200.03N/01208.09E'Flug-Sonderlandeplatz (PPR) Zerbst, Tower: 123,050 MHz, Metar: $EDDP
$call-10>BEACON,TCPIP*:;EDBF     *111111z5247.06N/01245.61E'Flugplatz Fehrbellin, Tower: 122,500 MHz, Metar: $EDDT
$call-10>BEACON,TCPIP*:;EDAE     *111111z5211.83N/01435.13E'Flugplatz Eisenhüttenstadt, Tower: 122,000 Mz, Metar:$EDDB
$call-10>BEACON,TCPIP*:;ETSH     *111111z5146.07N/01310.06E^Fliegerhorst Holzdorf (Flugplatz der Luftwafe), Metar: $ETSH
$call-10>APE001,WIDE1-1,TCPIP*::$call    :UNIT.°C,Votl,Vot,GB,kB
$call-10>APE001,WIDE1-1,TCPIP*::$call    :PARM.CPUCore Temp,CPUCore Volt,RAM Volt,UsedHDD GB,FreeMem kB
$call-10>APE001,WIDE1-1,TCPIP*::$call    :BITS.00000000,RaspberryPi Systemstatus
$call-10>APE001,WIDE1-1,TCPIP*:T#"`cat $zahl`\
","`vcgencmd measure_temp | awk -F'=' '{print $2}' | awk -F"'" '{print $1}'\
`","`vcgencmd measure_volts core | awk -F'=' '{print $2}' | awk -F'V' '{print $1}'`\
","`vcgencmd measure_volts sdram_p | awk -F'=' '{print $2}'| awk -F'V' '{print $1}'`\
","`df -h | grep "/dev/root" | awk '{print $3}' | awk -F"," '{print $1}'`"."`df -h | grep "/dev/root" | awk '{print $3}' | awk -F"," '{print $2}' | awk -F"G" '{print $1}
'`\
","`free | grep Mem | awk '{print $3}'`\
",000000"``\ > $TEMP/aprs-telemetrie.txt
quelle="$(cat $zahl)"
wert=1
zahlneu=$((quelle+wert))
echo $zahlneu > "$zahl"
rm $TEMP/EDD*
rm $TEMP/ETSH*
}

if ping -c 1 $hamnet > /dev/null;
 then
 echo "> HAMNET ist Online, es wird via HAMNET an $hamnet gesendet."
 echo "> Telemetrie-Daten werden erstellt."
 telemetrie
 nc -w 5 $hamnet 14580 < $TEMP/aprs-telemetrie.txt;
 python $PFAD/metar2aprs/metar2aprs.py EDDT EDDB ETNL ETSH EDAH;
 exit 0;
fi
 if ping -c 1 $internet > /dev/null;
    then
    echo "> HAMNET nicht Erreichbar, es wird via Internet an $internet gesendet."
    echo "> Telemetrie-Daten werden erstellt."
    telemetrie
    nc -w 5 $internet 14580 < $TEMP/aprs-telemetrie.txt;
    python $PFAD/metar2aprs/metar2aprs.py EDDT EDDB ETNL ETSH EDAH;
    exit 0;
 fi
    echo "> Es ist kein Netzwerk erreichbar, senden Abgebrochen."
    exit 0;