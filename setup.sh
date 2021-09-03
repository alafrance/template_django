##
## UTILITY
##

ask_something() { # $1 : prompt
	var=''
	while read -p "$1" var; do
		if [ "$var" != "" ] ; then break ; fi
	done
	echo $var
}

add_line() { # $1: match, $2: line_add , $3: file
	sed -e "/$1/a\\
	$2" $3 > tmp && rm -rf $3 && mv tmp $3
	rm -f tmp
}

replace_line() {
	sed "s/$1/$2/g" $3 > tmp
	rm -rf $3 ; mv tmp $3
}

add_line_without_tabulation() { # $1: match, $2: line_add , $3: file
	sed -e "/$1/a\\
$2" $3 > tmp && rm -rf $3 && mv tmp $3
	rm -f tmp
}

##
## CONFIG FUNCTION
##

add_vue_and_tailwind() { 
	add_line "django.contrib.staticfiles'," "'tailwind'," $project/settings.py
	python3 manage.py tailwind init
	add_line_without_tabulation "DEBUG" "TAILWIND_APP_NAME = 'theme'" $project/settings.py
	add_line "django.contrib.staticfiles'," "'theme'," $project/settings.py
	python3 manage.py tailwind install
	add_line "\<title\>" "$(cat ../data/html/vue_base.html)" templates/$app_name/base.html # add cdn vuejs in base.html
	add_line_without_tabulation "{% load static %}" "{% load tailwind_tags %}" templates/$app_name/base.html
	add_line "\<title\>" "{% tailwind_css %}" templates/$app_name/base.html
}

add_webpack() {
	cp ../data/webpack.config.js .
	npm init -y
	npm install webpack webpack-cli --save-dev
	mkdir assets
	cd assets && mkdir js css && cd ..
	mkdir static
	cd static && mkdir css images js && cd ..
	cp ../data/index.js assets/js/.
	add_line "\"scripts\":" "	\"dev\": \"webpack --mode development --watch\"," package.json
	add_line_without_tabulation "STATIC_URL" "STATICFILES_DIRS \= \[" $project/settings.py
	add_line "STATICFILES_DIRS" "os.path.join(BASE_DIR, 'static')," $project/settings.py
	add_line_without_tabulation "os.path.join(BASE_DIR, 'static')," "]" $project/settings.py
	add_line "block body" "\<script src=\"\{% static 'js/index.js' %\}\"\>\</script\>" templates/$app_name/base.html
}

add_templates_folder() {
	mkdir templates && cd templates && mkdir $app_name && cd $app_name
	sed "s/APP_NAME/$app_name/g" ../../../data/html/template_index.html > index.html && cp ../../../data/html/base.html . && cd ../../ # add html files
	replace_line "'DIRS': \[\]," "'DIRS': \[os.path.join\(BASE_DIR, 'templates'\)\]," $project/settings.py
}

config_app() {
	add_line_without_tabulation "from pathlib import Path" "import os" $project/settings.py
	python3 manage.py startapp $app_name ; if [ $? != 0 ] ; then return 0 ; fi
	add_templates_folder
	cd $app_name
	sed "s/APP_NAME/$app_name/g" ../../data/template_views.py > views.py # add views
	cp -rf ../../data/urls.py . # add urls file
	cd ../$project
	add_line "'django.contrib.staticfiles'," "'$app_name'," settings.py # add app in settings file
	add_line "urlpatterns = \[" "path('', include('$app_name.urls'))," urls.py # add path in urls file
	sed '/from django.urls import path/s/$/, include/' urls.py > tmp && rm -rf urls.py && mv tmp urls.py # add function include
	cd ..
}

add_livereload() {
	add_line "'django.contrib.messages'," "'livereload'," $project/settings.py
	add_line "'django.middleware.clickjacking.XFrameOptionsMiddleware'," "'livereload.middleware.LiveReloadScript'," $project/settings.py
}

##
## MAIN FUNCTION
##

main() {
	django-admin startproject $project
	if [ $? != 0 ] ; then return 0 ; fi
	cd $project
	config_app
	add_webpack
	if [[ "$is_vue" == 'y' || "$is_vue" == "yes" ]] ; then
		add_vue_and_tailwind
	fi
	add_livereload
	cd ..
}

project=$(ask_something "Your project name : ")
is_vue=$(ask_something "Do you want vue and tailwind, yes/no : ")
app_name=$(ask_something "App name : ")
main $project
is_delete=$(ask_something "Do you want delete script and data. y/n, yes/no : ")
if [[ "$is_delete" == 'y' || "$is_delete" == "yes" ]] ; then
	rm -rf data setup.sh
fi