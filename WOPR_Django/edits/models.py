# This is an auto-generated Django model module.
# You'll have to do the following manually to clean this up:
#   * Rearrange models' order
#   * Make sure each model has one field with primary_key=True
#   * Make sure each ForeignKey has `on_delete` set to the desired behavior.
#   * Remove `managed = False` lines if you wish to allow Django to create, modify, and delete the table
# Feel free to rename the models, but don't rename db_table values or field names.
from django.db import models


class TCircuits(models.Model):
    circuitid = models.IntegerField(db_column='CircuitID', primary_key=True)  # Field name made lowercase.
    id = models.IntegerField(db_column='ID')  # Field name made lowercase.
    siteid = models.IntegerField(db_column='siteID', blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 't_Circuits'
        unique_together = (('circuitid', 'id'),)


class TEdits(models.Model):
    editid = models.AutoField(db_column='EditID', primary_key=True)  # Field name made lowercase.
    ts_edit = models.DateTimeField()
    siteid = models.IntegerField(db_column='siteID')  # Field name made lowercase.
    id = models.IntegerField()
    period_from = models.IntegerField()
    period_to = models.IntegerField()
    fieldid = models.IntegerField(db_column='fieldID')  # Field name made lowercase.
    ts_editstart = models.DateTimeField(db_column='ts_EditStart')  # Field name made lowercase.
    ts_editend = models.DateTimeField(db_column='ts_EditEnd')  # Field name made lowercase.
    username = models.CharField(max_length=200)
    comment = models.CharField(max_length=2000, blank=True, null=True)
    newval = models.IntegerField(db_column='newVal', blank=True, null=True)  # Field name made lowercase.
    newvalfloat = models.FloatField(db_column='newValFloat', blank=True, null=True)  # Field name made lowercase.
    note = models.CharField(max_length=2000, blank=True, null=True)
    groupid = models.IntegerField(db_column='groupID', blank=True, null=True)  # Field name made lowercase.
    newval2 = models.IntegerField(db_column='newVal2', blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 't_Edits'


class TEnergydata(models.Model):
    siteid = models.ForeignKey('TSites', models.DO_NOTHING, db_column='siteID')  # Field name made lowercase.
    id = models.ForeignKey('TSiteconfig', models.DO_NOTHING, db_column='id')
    ts = models.DateTimeField()
    periodid = models.BigIntegerField(db_column='periodID', primary_key=True, db_index=True)  # Field name made lowercase.
    nws = models.FloatField(blank=True, null=True)
    kw_net = models.FloatField(blank=True, null=True)
    kw_exp = models.FloatField(blank=True, null=True)
    validfrom = models.DateTimeField(db_column='validFrom')  # Field name made lowercase.
    validto = models.DateTimeField(db_column='validTo')  # Field name made lowercase.
    kw_min_exp = models.FloatField(db_column='kW_min_exp', blank=True, null=True)  # Field name made lowercase.
    curtailed = models.SmallIntegerField()
    edited = models.SmallIntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 't_EnergyData'
        unique_together = (('siteid', 'id', 'periodid'),)

    def __str__(self):
        return str(self.siteid) + ' ' +  str(self.id) + ', ' + str(self.periodid)


class TEventcodes(models.Model):
    eventid = models.IntegerField(db_column='EventID', primary_key=True)  # Field name made lowercase.
    description = models.CharField(db_column='Description', max_length=500, blank=True, null=True)  # Field name made lowercase.
    defaultstateid = models.IntegerField(db_column='DefaultStateID')  # Field name made lowercase.
    defaultsystemid = models.IntegerField(db_column='DefaultSystemID')  # Field name made lowercase.
    turbtypeid = models.IntegerField(db_column='TurbTypeID')  # Field name made lowercase.
    actionid = models.IntegerField(db_column='ActionID')  # Field name made lowercase.
    eventlevel = models.IntegerField(db_column='EventLevel')  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 't_EventCodes'
        unique_together = (('eventid', 'turbtypeid'),)


class TEventdata(models.Model):
    siteid = models.ForeignKey('TSites', models.DO_NOTHING, db_column='SiteID')   # Field name made lowercase.
    id = models.ForeignKey('TSiteconfig', models.DO_NOTHING, db_column='ID')  # Field name made lowercase.
    ts_start = models.DateTimeField()
    eventid = models.IntegerField(db_column='EventID')  # Field name made lowercase.
    param1 = models.FloatField(blank=True, null=True)
    param2 = models.FloatField(blank=True, null=True)
    stateid = models.IntegerField(db_column='StateID', blank=True, null=True)  # Field name made lowercase.
    systemid = models.IntegerField(db_column='SystemID', blank=True, null=True)  # Field name made lowercase.
    ts_end = models.DateTimeField()
    periodid = models.BigIntegerField(db_column='periodID', primary_key=True)  # Field name made lowercase.
    eventkey = models.BigIntegerField(db_column='EventKey')  # Field name made lowercase.
    statekey = models.BigIntegerField(db_column='StateKey', blank=True, null=True)  # Field name made lowercase.
    systemkey = models.BigIntegerField(db_column='SystemKey', blank=True, null=True)  # Field name made lowercase.
    validfrom = models.DateTimeField(db_column='ValidFrom')  # Field name made lowercase.
    validto = models.DateTimeField(db_column='ValidTo')  # Field name made lowercase.
    duration_ms = models.IntegerField()

    class Meta:
        managed = False
        db_table = 't_EventData'


class TEventdataEdited(models.Model):
    siteid = models.IntegerField(db_column='SiteID', primary_key=True)  # Field name made lowercase.
    id = models.IntegerField(db_column='ID')  # Field name made lowercase.
    ts_start = models.DateTimeField()
    eventid = models.IntegerField(db_column='EventID')  # Field name made lowercase.
    param1 = models.FloatField(blank=True, null=True)
    param2 = models.FloatField(blank=True, null=True)
    stateid = models.IntegerField(db_column='StateID', blank=True, null=True)  # Field name made lowercase.
    systemid = models.IntegerField(db_column='SystemID', blank=True, null=True)  # Field name made lowercase.
    ts_end = models.DateTimeField()
    periodid = models.BigIntegerField(db_column='periodID')  # Field name made lowercase.
    eventkey = models.BigIntegerField(db_column='EventKey')  # Field name made lowercase.
    statekey = models.BigIntegerField(db_column='StateKey', blank=True, null=True)  # Field name made lowercase.
    systemkey = models.BigIntegerField(db_column='SystemKey', blank=True, null=True)  # Field name made lowercase.
    validfrom = models.DateTimeField(db_column='ValidFrom')  # Field name made lowercase.
    validto = models.DateTimeField(db_column='ValidTo')  # Field name made lowercase.
    duration_ms = models.IntegerField()

    class Meta:
        managed = False
        db_table = 't_EventData_edited'
        unique_together = (('siteid', 'id', 'periodid'),)


class TGroupmembers(models.Model):
    groupid = models.IntegerField(db_column='GroupID', primary_key=True)  # Field name made lowercase.
    id = models.IntegerField(db_column='ID')  # Field name made lowercase.
    siteid = models.IntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 't_GroupMembers'
        unique_together = (('groupid', 'id'),)


class TKksnames(models.Model):
    kks_name = models.CharField(db_column='KKS_Name', primary_key=True, max_length=50)  # Field name made lowercase.
    description = models.CharField(db_column='Description', max_length=50, blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 't_KKSNames'


class TProvinces(models.Model):
    provinceid = models.IntegerField(db_column='ProvinceID', blank=True, null=True)  # Field name made lowercase.
    province = models.CharField(db_column='Province', max_length=50, blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 't_Provinces'


class TRegions(models.Model):
    regioncode = models.IntegerField(db_column='RegionCode', blank=True, null=True)  # Field name made lowercase.
    regionname = models.CharField(db_column='RegionName', max_length=50, blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 't_Regions'


class TSiteconfig(models.Model):
    siteid = models.ForeignKey('TSites', models.DO_NOTHING, db_column='siteID')  # Field name made lowercase.
    id = models.IntegerField(db_column='ID', primary_key=True)  # Field name made lowercase.
    turbine = models.CharField(db_column='Turbine', max_length=255)  # Field name made lowercase.
    kksname = models.CharField(db_column='KKSName', max_length=255)  # Field name made lowercase.
    turbtypeid = models.IntegerField(db_column='turbTypeID')  # Field name made lowercase.
    pad = models.IntegerField(db_column='Pad', blank=True, null=True)  # Field name made lowercase.
    gearboxfrom = models.DateTimeField(db_column='GearboxFrom', blank=True, null=True)  # Field name made lowercase.
    gearbox_make = models.CharField(db_column='Gearbox Make', max_length=255, blank=True, null=True)  # Field name made lowercase. Field renamed to remove unsuitable characters.
    gearbox_model = models.CharField(db_column='Gearbox Model', max_length=255, blank=True, null=True)  # Field name made lowercase. Field renamed to remove unsuitable characters.
    generatorfrom = models.DateTimeField(db_column='GeneratorFrom', blank=True, null=True)  # Field name made lowercase.
    generator_make = models.CharField(db_column='Generator Make', max_length=255, blank=True, null=True)  # Field name made lowercase. Field renamed to remove unsuitable characters.
    generator_model = models.CharField(db_column='Generator Model', max_length=255, blank=True, null=True)  # Field name made lowercase. Field renamed to remove unsuitable characters.
    nn1 = models.IntegerField(blank=True, null=True)
    nn2 = models.IntegerField(blank=True, null=True)
    includeinsitetotals = models.SmallIntegerField(db_column='IncludeInSiteTotals')  # Field name made lowercase.
    mw = models.DecimalField(db_column='MW', max_digits=18, decimal_places=3, blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 't_SiteConfig'
        unique_together = (('siteid', 'id'),)


class TStates(models.Model):
    stateid = models.IntegerField(db_column='StateID', primary_key=True)  # Field name made lowercase.
    state = models.CharField(db_column='State', max_length=255, blank=True, null=True)  # Field name made lowercase.
    description = models.CharField(db_column='Description', max_length=255, blank=True, null=True)  # Field name made lowercase.
    hydrocode = models.IntegerField(db_column='hydroCode', blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 't_States'


class TSystems(models.Model):
    systemid = models.IntegerField(db_column='SystemID', primary_key=True)  # Field name made lowercase.
    system = models.CharField(db_column='System', max_length=255, blank=True, null=True)  # Field name made lowercase.
    description = models.CharField(db_column='Description', max_length=255, blank=True, null=True)  # Field name made lowercase.
    defined_state = models.CharField(db_column='Defined State', max_length=255, blank=True, null=True)  # Field name made lowercase. Field renamed to remove unsuitable characters.
    examples = models.CharField(db_column='Examples', max_length=255, blank=True, null=True)  # Field name made lowercase.
    definedstateid = models.IntegerField(db_column='DefinedStateID', blank=True, null=True)  # Field name made lowercase.
    hydrocode = models.IntegerField(db_column='hydroCode', blank=True, null=True)  # Field name made lowercase.
    systemcategory = models.CharField(db_column='SystemCategory', max_length=255, blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 't_Systems'


class TWoprnotes(models.Model):
    siteid = models.IntegerField(db_column='SiteID', primary_key=True)  # Field name made lowercase.
    id = models.IntegerField(db_column='ID')  # Field name made lowercase.
    periodid = models.BigIntegerField(db_column='periodID')  # Field name made lowercase.
    username = models.CharField(db_column='Username', max_length=50)  # Field name made lowercase.
    note = models.CharField(db_column='Note', max_length=4000)  # Field name made lowercase.
    ts_utc = models.DateTimeField(db_column='ts_UTC', blank=True, null=True)  # Field name made lowercase.
    notificationid = models.IntegerField(db_column='notificationID', blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 't_WOPRNotes'
        unique_together = (('siteid', 'id', 'periodid'),)


class TGroups(models.Model):
    groupid = models.IntegerField(db_column='GroupID', primary_key=True)  # Field name made lowercase.
    siteid = models.IntegerField(db_column='SiteID', blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 't_groups'


class TPowercurves(models.Model):
    siteid = models.IntegerField(db_column='siteID', primary_key=True)  # Field name made lowercase.
    id = models.IntegerField()
    nws_bin = models.DecimalField(max_digits=5, decimal_places=1)
    kw = models.FloatField(db_column='kW', blank=True, null=True)  # Field name made lowercase.
    kw_min = models.FloatField(blank=True, null=True)
    kw_max = models.FloatField(blank=True, null=True)
    kw_std = models.FloatField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 't_powerCurves'
        unique_together = (('siteid', 'id', 'nws_bin'),)


class TSites(models.Model):
    siteid = models.IntegerField(db_column='SiteID', primary_key=True)  # Field name made lowercase.
    description = models.CharField(db_column='Description', max_length=100)  # Field name made lowercase.
    doimportflow = models.IntegerField(db_column='doImportFlow')  # Field name made lowercase.
    dsnid = models.IntegerField(db_column='DSNID', blank=True, null=True)  # Field name made lowercase.
    strwstagname = models.CharField(db_column='strWSTagName', max_length=100, blank=True, null=True)  # Field name made lowercase.
    strkwtagname = models.CharField(db_column='strkWTagName', max_length=100, blank=True, null=True)  # Field name made lowercase.
    streventtagname = models.CharField(db_column='strEventTagName', max_length=100, blank=True, null=True)  # Field name made lowercase.
    strdsn = models.CharField(db_column='strDSN', max_length=100, blank=True, null=True)  # Field name made lowercase.
    tz_offsetfromhistorian_h = models.IntegerField(db_column='tz_offsetFromHistorian_h')  # Field name made lowercase.
    eventmod1000 = models.SmallIntegerField(db_column='EventMod1000')  # Field name made lowercase.
    strstatustagname = models.CharField(db_column='strStatusTagName', max_length=100, blank=True, null=True)  # Field name made lowercase.
    nnsite1 = models.IntegerField(db_column='nnSite1', blank=True, null=True)  # Field name made lowercase.
    nnsite2 = models.IntegerField(db_column='nnSite2', blank=True, null=True)  # Field name made lowercase.
    albertasmp = models.SmallIntegerField(db_column='AlbertaSMP', blank=True, null=True)  # Field name made lowercase.
    greencreditstart = models.DateTimeField(db_column='GreenCreditStart', blank=True, null=True)  # Field name made lowercase.
    greencreditend = models.DateTimeField(db_column='GreenCreditEnd', blank=True, null=True)  # Field name made lowercase.
    greencredit_cd = models.FloatField(db_column='GreenCredit_cd', blank=True, null=True)  # Field name made lowercase.
    ppaescalation = models.CharField(db_column='PPAEscalation', max_length=200, blank=True, null=True)  # Field name made lowercase.
    greencreditstartperiod = models.BigIntegerField(db_column='GreenCreditStartPeriod', blank=True, null=True)  # Field name made lowercase.
    greencreditendperiod = models.BigIntegerField(db_column='GreenCreditEndPeriod', blank=True, null=True)  # Field name made lowercase.
    power_in_mw = models.SmallIntegerField(db_column='Power_in_MW', blank=True, null=True)  # Field name made lowercase.
    importtimeoffset_h = models.IntegerField(db_column='importTimeOffset_h', blank=True, null=True)  # Field name made lowercase.
    capacity_mw = models.FloatField(db_column='Capacity_MW', blank=True, null=True)  # Field name made lowercase.
    jvrate = models.FloatField(db_column='JVRate', blank=True, null=True)  # Field name made lowercase.
    financereportordering = models.IntegerField(db_column='FinanceReportOrdering', blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 't_sites'

    def getSiteDescription(self):
        return self.description

    def __str__(self):
        return str(self.siteid) + " - " + self.description


class TTurbtypes(models.Model):
    turbtypeid = models.FloatField(db_column='TurbTypeID', primary_key=True)  # Field name made lowercase.
    description = models.CharField(db_column='Description', max_length=255, blank=True, null=True)  # Field name made lowercase.
    mw = models.FloatField(db_column='MW', blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 't_turbTypes'















