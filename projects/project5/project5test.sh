#!/bin/bash
#Author: Thanh Ky Quan
yellow='\E[1;33m'
red='\E[1;31m'
default='\033[1m\033[0m'
green='\E[1;32m'
defaultPort=4002
port=$defaultPort
corruptionRate=0.0
totalTest=100
passedTest=0
host="localhost"
if [ -a "out.txt" ]; then
  rm "out.txt"
fi
echo -e "$yellow"
echo "---------------------------------------------------"
echo "          CS 2200 - Project 5 Autotester           "
echo "          Author: Thanh Ky Quan                    "
echo "          2013                                     "
echo "---------------------------------------------------"

echo -e "$white"
echo "Attempt to compile..."
# Clean old files
make clean > /dev/null 2>&1

# Make
compileLine=$(make 2>/dev/null | wc -l)

if [ $compileLine -eq 2 ]; then
  echo -en "$green"
  echo "Success"
else
  echo -en "$red"
  echo "Fail"
  echo -en "$default"
  make
  exit
fi;

echo -en "$yellow"
echo "Stopping all running instance"
sudo kill `lsof -t -i:$port` 2&>1 >/dev/null
sleep 1
echo "Attempting to launch server at port $port"
bindPortCheck=$(((./prj5-server $port $corruptionRate 1 2>&1 >/dev/null) & sleep 1; kill $! 2>&1 > /dev/null) | grep "Could not bind" | wc -c)
while [ $bindPortCheck -gt 0 ]; do
    echo -en "$red"
    echo "Could not bind to port $port. Moving to the next one"
    port=$(echo "$port+1" | bc)
    bindPortCheck=$(((./prj5-server $port $corruptionRate 1 2>&1 >/dev/null) & sleep 1; kill $! 2>&1 > /dev/null) | grep "Could not bind" | wc -c)
done
echo -en "$green"
echo "Successfully running server at port $port"

testRun=0
while [ $testRun -lt $totalTest ]; do
  checkPort=0
  out=""
  sudo kill `lsof -t -i:$port` 2&>1 >/dev/null 
  sudo pkill "prj5-server"
  out=$(./prj5-server $port $corruptionRate 1 2>&1 & sleep .5; kill $! 2&>1 >/dev/null) 
  
  checkPort=$(echo "$out" | grep "Could not bind" | wc -l)
  if [ $checkPort -gt 0 ]; then
    port=$(echo "$port + 1" | bc)
  else
    out=$(./prj5-server $port $corruptionRate 1 2>&1 & (sleep .1 && ./prj5-client $host $port 2>&1) & sleep 1; sudo kill `lsof -t -i:$port` 2>&1 >/dev/null)
    checkTest=$(echo "$out" | grep "Alexay oweLay" | wc -c)
    if [ $checkTest -gt 0 ]; then
      passedTest=$(echo "$passedTest + 1" | bc)
      echo -en "$green"
      echo "Passed test $passedTest"
      echo -en "$default"
    else
      echo -en "$red"
      echo "Fail at corruption rate equals $corruptionRate, probably terminated early due to machine's speed"
      echo -en "$default"
      echo "$out"
    fi;
    testRun=$(echo "$testRun + 1" | bc)
    #increase corruptionRate
    corruptionRate=$(echo "$corruptionRate + 0.01" | bc)
  fi
done
echo ""
echo "Passed $passedTest / $totalTest"
if [ $passedTest -eq 100 ]; then
  echo "Congrats! I'm impressed!"
else
  if [ $passedTest -gt 90 ]; then
    echo "You are deserved an A"
  else 
    if [ $passedTest -gt 80 ]; then
      echo "Try a bit harder!!!"
    else
      if [ $passedTest -gt 70 ]; then
	echo "Well, all I can say is you're passed!"
      else
	echo "Hmm, there are many things need to be done..."
      fi
    fi
  fi
fi;

# reset color to normal
echo -en "$default"
