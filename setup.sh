add_vue() {
	echo "We gonna add vue bitch !"
}

add_django_folder() {
	django-admin startproject $1
	if [ $? != 0 ] ; then
		return 0
	fi
	cd $1
	app_name=$(ask_something "App name : ")
	python3 manage.py startapp $app_name
	if [ $? != 0 ] ; then
		return 0
	fi
	cd $app_name
	mkdir templates && cd templates && mkdir $app_name && cd $app_name && touch index.html && cd ../../
	rm views.py && cp -rf ../../data/views.py .
	cp -rf ../../data/urls.py .
	cd ..
	cd $1
	sed -e "/django.contrib.staticfiles',/a\\
	'$app_name'," settings.py > file.txt && rm -rf settings.py && mv file.txt settings.py
}

ask_something() {
	var=''
	while read -p "$1" var; do
		if [ "$var" != "" ] ; then break ; fi
	done
	echo $var
}

project=$(ask_something "Your project name : ")
add_django_folder $project
# is_vue=$(ask_something "Do you want vuejs, y/n, yes/no : ")
# if [[ "$is_vue" == 'y' || "$is_vue" == "yes" ]] ; then
# 	add_vue
# fi

