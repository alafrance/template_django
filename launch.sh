if [[ -z $1 ]] || [[ ! -d $1 ]] ; then echo "Error parameter, need specify project name" && exit 1 ; fi

startvue() {
	if [[ -d "vueapp" ]]
	then
		cd vueapp
		yarn build --watch &> /dev/null
	fi
}

startlivereload() {
	python3 manage.py livereload
}

startserver() {
	python3 manage.py migrate
	python3 manage.py runserver
}

starttailwind() {
	python3 manage.py tailwind start
}

startvue_pid=0
startserver_pid=0
cd $1
startvue &
startvue_pid=$!
startlivereload &
startlivereload_pid=$!

trap ctrl_c INT
ctrl_c() {
	kill $startvue_pid
	kill $startlivereload_pid
	exit
}

startserver

## I NEED TO CALL STARTTAILWIND FUNCTION BUT DOESN'T WORK IN OTHER PROCESS