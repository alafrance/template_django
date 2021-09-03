if [[ -z $1 ]] || [[ ! -d $1 ]] ; then echo "Error parameter, need specify project name" && exit 1 ; fi


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

startwebpack() {
	npm run dev
}

cd $1
startlivereload &
startlivereload_pid=$!
startwebpack &
startwebpack_pid=$!

trap ctrl_c INT
ctrl_c() {
	kill $startvue_pid
	kill $startlivereload_pid
	kill $startwebpack_pid
	exit
}

startserver

## I NEED TO CALL STARTTAILWIND FUNCTION BUT DOESN'T WORK IN OTHER PROCESS