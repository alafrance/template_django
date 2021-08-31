from django.http import render # on recupere httpresponse


def index(request): # index retournera ce html la
    return render(request, 'myapp/index.html')