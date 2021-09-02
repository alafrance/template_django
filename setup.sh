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

add_line_without_tabulation() { # $1: match, $2: line_add , $3: file
	sed -e "/$1/a\\
$2" $3 > tmp && rm -rf $3 && mv tmp $3
	rm -f tmp
}

##
## CONFIG FUNCTION
##

add_vue() { 
	add_line "{% block body %}{% endblock body %}" "$(cat ../data/html/vue_base.html)" $app_name/templates/$app_name/base.html # add script vuejs in base.html
	add_line_without_tabulation "STATIC_URL" "STATIC_ROOT = 'var\/static_root\/'" $project/settings.py
	add_line_without_tabulation "STATIC_ROOT" "STATICFILES_DIRS = \['static'\]" $project/settings.py
	vue create vueapp
	cp ../data/vue.config.js vueapp/
	cd vueapp ; yarn build ; cd ..
	python3 manage.py collectstatic
}

config_app() {
	python3 manage.py startapp $app_name ; if [ $? != 0 ] ; then return 0 ; fi
	cd $app_name
	rm views.py ; sed "s/APP_NAME/$app_name/g" ../../data/template_views.py > views.py # add views
	mkdir templates && cd templates && mkdir $app_name && cd $app_name # create html folder
	sed "s/APP_NAME/$app_name/g" ../../../../data/html/template_index.html > index.html && cp ../../../../data/html/base.html . && cd ../../ # add html files
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
	if [[ "$is_vue" == 'y' || "$is_vue" == "yes" ]] ; then
	add_vue
	fi
	add_livereload
	cd ..
}

project=$(ask_something "Your project name : ")
is_vue=$(ask_something "Do you want vuejs, y/n, yes/no : ")
app_name=$(ask_something "App name : ")
main $project
rm -rf data setup.sh