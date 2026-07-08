
mod_time=$(stat -c "%Y" main.lua)
echo "Mod time is $mod_time"
love . &
love_pid=$!
echo "PID is $love_pid"

while :
do

	temp_mod_time=$(stat -c "%Y" main.lua)

	if [ $temp_mod_time -gt $mod_time ]; then
		mod_time=$temp_mod_time
		echo "Mod time is $mod_time"
		kill -9 $love_pid
		love . &
		love_pid=$!
		echo "PID is $love_pid"
	fi

	sleep 3

done
