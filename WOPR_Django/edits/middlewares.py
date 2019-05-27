import pytz

from django.utils import timezone
from django.utils.deprecation import MiddlewareMixin

class TimezoneMiddleware(MiddlewareMixin):
    def process_request(self, request):
        tzname = request.session.get('django_timezone')
        if tzname:
            timezone.activate(pytz.timezone(tzname))
            print('TimezoneMiddleware activated timezone to', tzname)

        else:
            timezone.deactivate()
            print('TimezoneMiddleware did not detect the timezone of user. Setting timezone to default defined in settings.py' )