#!/bin/bash

echo "Machine name :$(hostnamectl | grep -i static | cut -d":" -f2)"
echo "OS $(source /etc/os-release;echo $NAME) and kernel version is $(uname -v)"
echo "IP : $(ip a | grep global | grep inet | tr -s ' ' | cut -d" " -f3 | head -n1)"
echo "RAM : $(free -h | tr -s ' ' | cut -d" " -f4 | head -n2 | tail -n1) memory available on $(free -h | tr -s ' ' | cut -d" " -f2 | head -n2 | tail -n1) total memory"
echo "Disk : $(df -h | tr -s ' ' | cut -d" " -f2 | head -n5 | tail -n1) space left"
echo "Top 5 processes by RAM usage :"
for i in {1..5}; do
  echo "   - $(ps aux | sort -rnk 4 | tr -s ' ' | cut -d" " -f11- | head -n$i | tail -n1)"
done
echo "Listening ports : "
while read var;
do
  port=$(echo "${var}" | cut -d" " -f5 | cut -d":" -f2)
  protocol=$(echo "${var}" | cut -d" " -f1)
  process=$(echo "${var}" | cut -d'"' -f2)
  echo "  - ${port} ${protocol} : ${process}"
done <<< $(sudo ss -ltupn4H | tr -s ' ')

curl https://cataas.com/cat > cat.jpg

echo "Here is your random cat : $(find cat.jpg)"
