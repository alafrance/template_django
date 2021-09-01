from django.shortcuts import render

def index(request):
    return render(request, 'APP_NAME/index.html')