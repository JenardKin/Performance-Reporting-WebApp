from django.contrib import admin
from .models import TEnergydata, TEventdata, TSiteconfig, TSites, TEdits
# Register your models here.
admin.site.register(TEnergydata)
admin.site.register(TEventdata)
admin.site.register(TSiteconfig)
admin.site.register(TSites)
admin.site.register(TEdits)
