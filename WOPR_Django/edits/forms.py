from django import forms
#from .widgets import BootstrapDateTimePickerInput
from edits.utils import *
#from django import forms
from .widgets import XDSoftDateTimePickerInput
from django.core.validators import FileExtensionValidator


class UploadIESOFileForm(forms.Form):
    IESO_file = forms.FileField(validators=[FileExtensionValidator(allowed_extensions=['xlsx'])])
    useMidnight = forms.BooleanField(initial=True, required=False)

# class SiteDateTimeForm(forms.Form):
#     site_id = forms.CharField() # this needs to be a list from the database... kinda like below birth year picker
#     start_time = forms.DateTimeField(input_formats=['%d/%m/%Y %H:%M'], widget=XDSoftDateTimePickerInput())
#     end_time = forms.DateTimeField(input_formats=['%d/%m/%Y %H:%M'], widget=XDSoftDateTimePickerInput()) #2012-03-10 14:30

class SiteDateTimeForm(forms.Form):
    CHOICES = makeChoicesList_EditsQualityCheck()
    site_id = forms.CharField(widget=forms.Select(choices=CHOICES)) # this needs to be a list from the database... kinda like below birth year picker
    start_time = forms.DateTimeField(input_formats=['%d/%m/%Y %H:%M'], widget=XDSoftDateTimePickerInput(attrs={'autocomplete':'off'}))
    end_time = forms.DateTimeField(input_formats=['%d/%m/%Y %H:%M'], widget=XDSoftDateTimePickerInput(attrs={'autocomplete':'off'})) #2012-03-10 14:30

class SiteTimeRangeForm(forms.Form):
    #CHOICES = makeSiteList()
    #site_id = forms.CharField(widget=forms.Select(choices=CHOICES)) 
    site_id = forms.ModelChoiceField(queryset=TSites.objects.all()) 
    start_time = forms.DateTimeField(input_formats=['%d/%m/%Y %H:%M'], widget=XDSoftDateTimePickerInput(attrs={'autocomplete':'off'}))
    end_time = forms.DateTimeField(input_formats=['%d/%m/%Y %H:%M'], widget=XDSoftDateTimePickerInput(attrs={'autocomplete':'off'}))
    def clean(self):
        cleaned_data = super().clean()
        start_time = cleaned_data.get("start_time")
        end_time = cleaned_data.get("end_time")
        if start_time and end_time:
            if end_time <= start_time:
                print(str(end_time)+"<="+str(start_time)+" returned "+str(end_time <= start_time))
                raise forms.ValidationError(" - ERROR - Please ensure the time range is valid.")
                #self.add_error('start_time', "Please ensure the time range is valid.")
                #self.add_error('end_time', "Please ensure the time range is valid.")

class TimeRangeForm(forms.Form):
    start_time = forms.DateTimeField(input_formats=['%d/%m/%Y %H:%M'], widget=XDSoftDateTimePickerInput(attrs={'autocomplete':'off'}))
    end_time = forms.DateTimeField(input_formats=['%d/%m/%Y %H:%M'], widget=XDSoftDateTimePickerInput(attrs={'autocomplete':'off'}))
    def clean(self):
        cleaned_data = super().clean()
        start_time = cleaned_data.get("start_time")
        end_time = cleaned_data.get("end_time")
        if start_time and end_time:
            if end_time <= start_time:
                print(str(end_time)+"<="+str(start_time)+" returned "+str(end_time <= start_time))
                raise forms.ValidationError(" - ERROR - Please ensure the time range is valid.")

class TurbineSelectionForm(forms.Form):
    # Default values
    CHOICES = list(range(1, 100))
    start_time = forms.DateTimeField(input_formats=['%d/%m/%Y %H:%M'], widget=XDSoftDateTimePickerInput(attrs={'autocomplete':'off'}))
    end_time = forms.DateTimeField(input_formats=['%d/%m/%Y %H:%M'], widget=XDSoftDateTimePickerInput(attrs={'autocomplete':'off'}))
    view_turbines_from = forms.ChoiceField(choices=CHOICES)
    view_turbines_till = forms.ChoiceField(choices=CHOICES)

    # Constructor with parameters
    def __init__(self, *args,**kwargs):
        self.siteid = kwargs.pop('siteid')
        self.CHOICES = makeTurbineList(self.siteid)
        super(TurbineSelectionForm, self).__init__(*args, **kwargs)
        self.fields['view_turbines_from'] = forms.ChoiceField(choices=self.CHOICES)
        self.fields['view_turbines_till'] = forms.ChoiceField(choices=self.CHOICES, initial=str(len(self.CHOICES)))

class SiteSelectionForm(forms.Form):
    CHOICES = makeSiteList()
    site_id = forms.CharField(label='Site', widget=forms.Select(choices=CHOICES)) # this needs to be a list from the database... kinda like below birth year picker

class FilterDashboardForm(forms.Form):
    # Default values
    CHOICES = ['Turbine' + str(i + 1) for i in range(1, 100)]
    start_time = forms.DateTimeField(label='From Time', input_formats=['%d/%m/%Y %H:%M'], widget=XDSoftDateTimePickerInput(attrs={'autocomplete':'off'}))
    end_time = forms.DateTimeField(label='Till Time', input_formats=['%d/%m/%Y %H:%M'], widget=XDSoftDateTimePickerInput(attrs={'autocomplete':'off'}))
    id_from = forms.ChoiceField(label='From Turbine', choices=CHOICES)
    id_till = forms.ChoiceField(label='Till Turbine', choices=CHOICES)

    # Constructor with parameters
    def __init__(self, *args,**kwargs):
        self.siteid = kwargs.pop('siteid')
        self.id_from = kwargs.pop('id_from')
        self.id_till = kwargs.pop('id_till')
        self.CHOICES = makeTurbineList(self.siteid, self.id_from, self.id_till)
        self.lastIndex = self.CHOICES[len(self.CHOICES) - 1]
        super(FilterDashboardForm, self).__init__(*args, **kwargs)
        self.fields['id_from'] = forms.ChoiceField(label='From Turbine', choices=self.CHOICES)
        self.fields['id_till'] = forms.ChoiceField(label='Till Turbine', choices=self.CHOICES, initial=self.lastIndex)

    def clean(self):
        cleaned_data = super().clean()
        start_time = cleaned_data.get("start_time")
        end_time = cleaned_data.get("end_time")
        if start_time and end_time:
            if end_time <= start_time:
                print(str(end_time)+"<="+str(start_time)+" returned "+str(end_time <= start_time))
                raise forms.ValidationError(" - ERROR - Please ensure the time range is valid.")

class SiteTurbineTimeForm(forms.Form):
    CHOICES = makeSiteList()
    site_id = forms.CharField(widget=forms.Select(choices=CHOICES))
    turbine_id = forms.CharField(widget=forms.Select(choices={}))
    start_time = forms.DateTimeField(input_formats=['%d/%m/%Y %H:%M'], widget=XDSoftDateTimePickerInput(attrs={'autocomplete':'off'}))
    end_time = forms.DateTimeField(input_formats=['%d/%m/%Y %H:%M'], widget=XDSoftDateTimePickerInput(attrs={'autocomplete':'off'}))
    def clean(self):
        cleaned_data = super().clean()
        start_time = cleaned_data.get("start_time")
        end_time = cleaned_data.get("end_time")
        if start_time and end_time:
            if end_time <= start_time:
                print(str(end_time)+"<="+str(start_time)+" returned "+str(end_time <= start_time))
                raise forms.ValidationError(" - ERROR - Please ensure the time range is valid.")
                #self.add_error('start_time', "Please ensure the time range is valid.")
                #self.add_error('end_time', "Please ensure the time range is valid.")
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.fields['turbine_id'].queryset = TSiteconfig.objects.none().values("turbine")

        if 'site_id' in self.data:
            try:
                site = int(self.data.get('site_id')) #need site id too...
                self.fields['turbine_id'].queryset = TSiteconfig.objects.filter(siteid=site).values('turbine')
            except (ValueError, TypeError):
                pass  # invalid input from the client; ignore and fallback to empty turbine queryset
        
class CompareTurbinePowerForm(forms.Form):
    CHOICES = makeSiteList()
    site_id_1 = forms.CharField(widget=forms.Select(choices=CHOICES))
    turbine_id_1 = forms.CharField(widget=forms.Select(choices={}))
    start_time_1 = forms.DateTimeField(input_formats=['%d/%m/%Y %H:%M'], widget=XDSoftDateTimePickerInput(attrs={'autocomplete':'off'}))
    end_time_1 = forms.DateTimeField(input_formats=['%d/%m/%Y %H:%M'], widget=XDSoftDateTimePickerInput(attrs={'autocomplete':'off'}))

    site_id_2 = forms.CharField(widget=forms.Select(choices=CHOICES))
    turbine_id_2 = forms.CharField(widget=forms.Select(choices={}))
    start_time_2 = forms.DateTimeField(input_formats=['%d/%m/%Y %H:%M'], widget=XDSoftDateTimePickerInput(attrs={'autocomplete':'off'}))
    end_time_2 = forms.DateTimeField(input_formats=['%d/%m/%Y %H:%M'], widget=XDSoftDateTimePickerInput(attrs={'autocomplete':'off'}))
    def clean(self):
        cleaned_data = super().clean()
        start_time_1 = cleaned_data.get("start_time_1")
        end_time_1 = cleaned_data.get("end_time_1")
        start_time_2 = cleaned_data.get("start_time_2")
        end_time_2 = cleaned_data.get("end_time_2")
        if start_time_1 and end_time_1 and start_time_2 and end_time_2:
            if (end_time_1 <= start_time_1) or (end_time_2 <= start_time_2):
                print(str(end_time)+"<="+str(start_time)+" returned "+str(end_time <= start_time))
                raise forms.ValidationError(" - ERROR - Please ensure the time ranges are valid.")

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.fields['turbine_id_1'].queryset = TSiteconfig.objects.none().values("turbine")

        if 'site_id_1' in self.data:
            try:
                site = int(self.data.get('site_id_1')) #need site id too...
                self.fields['turbine_id_1'].queryset = TSiteconfig.objects.filter(siteid=site).values('turbine')
            except (ValueError, TypeError):
                pass  # invalid input from the client; ignore and fallback to empty turbine queryset
        if 'site_id_2' in self.data:
            try:
                site = int(self.data.get('site_id_2')) #need site id too...
                self.fields['turbine_id_2'].queryset = TSiteconfig.objects.filter(siteid=site).values('turbine')
            except (ValueError, TypeError):
                pass  # invalid input from the client; ignore and fallback to empty turbine queryset


class UsernameForm(forms.Form):
    CHOICES = [('knoske','knoske'), ('dseely','dseely'), ('llessard','llessard')]
    usernames = forms.CharField(label='User ', widget=forms.Select(choices=CHOICES))
    site_selected = forms.CharField(widget=forms.HiddenInput())

class EditsTableForm(forms.Form):
    start_time = forms.DateTimeField(input_formats=['%d/%m/%Y %H:%M'], widget=XDSoftDateTimePickerInput(attrs={'autocomplete':'off'}))
    end_time = forms.DateTimeField(input_formats=['%d/%m/%Y %H:%M'], widget=XDSoftDateTimePickerInput(attrs={'autocomplete':'off'}))
    CHOICES = [('knoske','knoske'), ('dseely','dseely'), ('llessard','llessard')]
    usernames = forms.CharField(label='User ', widget=forms.Select(choices=CHOICES))
    site_selected = forms.CharField(widget=forms.HiddenInput())
    def clean(self):
        cleaned_data = super().clean()
        start_time = cleaned_data.get("start_time")
        end_time = cleaned_data.get("end_time")
        if start_time and end_time:
            if end_time <= start_time:
                print(str(end_time)+"<="+str(start_time)+" returned "+str(end_time <= start_time))
                raise forms.ValidationError(" - ERROR - Please ensure the time range is valid.")




# class DateForm(forms.Form):
#     date = forms.DateTimeField(
#         input_formats=['%d/%m/%Y %H:%M'], 
#         widget=XDSoftDateTimePickerInput()
#     )

# class CommentForm(forms.Form):
#     name = forms.CharField()
#     url = forms.URLField()
#     comment = forms.CharField(widget=forms.Textarea)

# class oldSiteDateTimeForm(forms.Form):
#     site_id = forms.CharField()
#     start_time = forms.CharField(widget=forms.DateTimeInput())
#     end_time = forms.DateTimeField(widget=forms.DateTimeInput())

# class bsSiteDateTimeForm(forms.Form):
#     site_id = forms.CharField() # this needs to be a list from the database... kinda like below birth year picker
#     start_time = forms.DateTimeField(input_formats=['%d/%m/%Y %h:%M %A'], widget=BootstrapDateTimePickerInput())
#     end_time = forms.DateTimeField(input_formats=['%d/%m/%Y %h:%M %A'], widget=BootstrapDateTimePickerInput()) #2012-03-10 14:30

# class siteID_startTime_endTime(forms.Form):
#     siteID = forms.NumberInput()
#     startTime = forms.DateTimeInput()
#     endTime = forms.DateTimeInput()

# BIRTH_YEAR_CHOICES = ('1980', '1981', '1982')
# FAVORITE_COLORS_CHOICES = (
#     ('blue', 'Blue'),
#     ('green', 'Green'),
#     ('black', 'Black'),
# )



# class SimpleForm(forms.Form):
#     birth_year = forms.DateField(widget=forms.SelectDateWidget(years=BIRTH_YEAR_CHOICES))
#     favorite_colors = forms.MultipleChoiceField(
#         required=False,
#         widget=forms.CheckboxSelectMultiple,
#         choices=FAVORITE_COLORS_CHOICES,
#     )