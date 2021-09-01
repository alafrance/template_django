if [[ -z $1 ]] || [[ ! -d $1 ]] ; then echo "Error parameter" && exit 1 ; fi

startvue() {
	if [[ -d "vueapp" ]]
	then
		cd vueapp
		yarn build --watch &> /dev/null
	fi
}

startlivereload() {
	python manage.py livereload
}

startserver() {
	python3 manage.py migrate
	python3 manage.py runserver
}

ctrl_c() {
	kill $startvue_pid
	# kill $startlivereload_pid
	exit
}

trap ctrl_c INT

startvue_pid=0
startserver_pid=0
cd $1
startvue &
startvue_pid=$!
# startlivereload
# startlivereload_pid=$!
startserver
