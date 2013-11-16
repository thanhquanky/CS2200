#!/bin/bash
totalFCFSTest="16"
totalRRTest="256"
totalSPTest="16"
re='^[0-9]+$'
echo "---------------------------------------------------"
echo "          CS 2200 - Project 4 Autotester           "
echo "          Author: Thanh Ky Quan                    "
echo "          2013                                     "
echo "---------------------------------------------------"

echo "First come first serve"

fcfsPass="0"

#clean up
make clean > /dev/null 2>&1
#make
make > /dev/null 2>&1


for i in `seq 1 16 `; do
	#run
#	echo $i
	res=$(./os-sim ${i} | grep "Context" | wc -c)
	if [[ "$res" -eq "$res" ]] ; then
		if [ $res -gt 0 ] ; then
			fcfsPass=$(echo "$fcfsPass + 1" | bc)
		fi
	else
		echo $res;
	fi
done;
echo "Passed $fcfsPass/$totalFCFSTest tests for FCFS"



### Static priority ###
echo "Static priority"
spPass="0"
for i in `seq 1 16`; do
	#run
#	echo $i
	res=$(./os-sim ${i} -p| grep "Context" | wc -c)

	if [ $res -gt 0 ]
		then
			spPass=$(echo "$spPass + 1" | bc)
		fi
done;
	
echo "Passed $spPass/$totalSPTest test for SP"

### Round robin ###
echo "Round robin"
rrPass="0"
for i in `seq 1 16`; do
	#run
	for j in `seq 1 16`; do
		#./os-sim ${i} -r ${j}
#		echo $i $j
		res=$((./os-sim ${i} -r ${j})| grep "Context" | wc -c)
		if [ $res -gt 0 ]; then
			rrPass=$(echo "$rrPass + 1" | bc)
		fi
	done;
#	echo "Passed $rrPass/$totalRRTest test for RR"
done;
echo "Passed $rrPass/$totalRRTest test for RR"

total=$(echo "$rrPass + $spPass + $fcfsPass" | bc)
echo ""
if [ $total -eq 288 ]; then
	echo "You passed all the test. Congrats dude!";
else
	if [ $total -gt 200 ]; then
		echo "You still missed some test. Keep trying";
	else
		if [ $total -gt 100 ]; then
			echo "You missed lots of tests. Try harder";
		else
			echo "I am sorry man";
		fi
	fi
fi

