# Generated by Django 2.1.3 on 2019-03-11 23:50

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('edits', '0002_tedits'),
    ]

    operations = [
        migrations.CreateModel(
            name='TCircuits',
            fields=[
                ('circuitid', models.IntegerField(db_column='CircuitID', primary_key=True, serialize=False)),
                ('id', models.IntegerField(db_column='ID')),
                ('siteid', models.IntegerField(blank=True, db_column='siteID', null=True)),
            ],
            options={
                'db_table': 't_Circuits',
                'managed': False,
            },
        ),
        migrations.CreateModel(
            name='TEventcodes',
            fields=[
                ('eventid', models.IntegerField(db_column='EventID', primary_key=True, serialize=False)),
                ('description', models.CharField(blank=True, db_column='Description', max_length=500, null=True)),
                ('defaultstateid', models.IntegerField(db_column='DefaultStateID')),
                ('defaultsystemid', models.IntegerField(db_column='DefaultSystemID')),
                ('turbtypeid', models.IntegerField(db_column='TurbTypeID')),
                ('actionid', models.IntegerField(db_column='ActionID')),
                ('eventlevel', models.IntegerField(db_column='EventLevel')),
            ],
            options={
                'db_table': 't_EventCodes',
                'managed': False,
            },
        ),
        migrations.CreateModel(
            name='TEventdataEdited',
            fields=[
                ('siteid', models.IntegerField(db_column='SiteID', primary_key=True, serialize=False)),
                ('id', models.IntegerField(db_column='ID')),
                ('ts_start', models.DateTimeField()),
                ('eventid', models.IntegerField(db_column='EventID')),
                ('param1', models.FloatField(blank=True, null=True)),
                ('param2', models.FloatField(blank=True, null=True)),
                ('stateid', models.IntegerField(blank=True, db_column='StateID', null=True)),
                ('systemid', models.IntegerField(blank=True, db_column='SystemID', null=True)),
                ('ts_end', models.DateTimeField()),
                ('periodid', models.BigIntegerField(db_column='periodID')),
                ('eventkey', models.BigIntegerField(db_column='EventKey')),
                ('statekey', models.BigIntegerField(blank=True, db_column='StateKey', null=True)),
                ('systemkey', models.BigIntegerField(blank=True, db_column='SystemKey', null=True)),
                ('validfrom', models.DateTimeField(db_column='ValidFrom')),
                ('validto', models.DateTimeField(db_column='ValidTo')),
                ('duration_ms', models.IntegerField()),
            ],
            options={
                'db_table': 't_EventData_edited',
                'managed': False,
            },
        ),
        migrations.CreateModel(
            name='TGroupmembers',
            fields=[
                ('groupid', models.IntegerField(db_column='GroupID', primary_key=True, serialize=False)),
                ('id', models.IntegerField(db_column='ID')),
                ('siteid', models.IntegerField(blank=True, null=True)),
            ],
            options={
                'db_table': 't_GroupMembers',
                'managed': False,
            },
        ),
        migrations.CreateModel(
            name='TGroups',
            fields=[
                ('groupid', models.IntegerField(db_column='GroupID', primary_key=True, serialize=False)),
                ('siteid', models.IntegerField(blank=True, db_column='SiteID', null=True)),
            ],
            options={
                'db_table': 't_groups',
                'managed': False,
            },
        ),
        migrations.CreateModel(
            name='TKksnames',
            fields=[
                ('kks_name', models.CharField(db_column='KKS_Name', max_length=50, primary_key=True, serialize=False)),
                ('description', models.CharField(blank=True, db_column='Description', max_length=50, null=True)),
            ],
            options={
                'db_table': 't_KKSNames',
                'managed': False,
            },
        ),
        migrations.CreateModel(
            name='TPowercurves',
            fields=[
                ('siteid', models.IntegerField(db_column='siteID', primary_key=True, serialize=False)),
                ('id', models.IntegerField()),
                ('nws_bin', models.DecimalField(decimal_places=1, max_digits=5)),
                ('kw', models.FloatField(blank=True, db_column='kW', null=True)),
                ('kw_min', models.FloatField(blank=True, null=True)),
                ('kw_max', models.FloatField(blank=True, null=True)),
                ('kw_std', models.FloatField(blank=True, null=True)),
            ],
            options={
                'db_table': 't_powerCurves',
                'managed': False,
            },
        ),
        migrations.CreateModel(
            name='TProvinces',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('provinceid', models.IntegerField(blank=True, db_column='ProvinceID', null=True)),
                ('province', models.CharField(blank=True, db_column='Province', max_length=50, null=True)),
            ],
            options={
                'db_table': 't_Provinces',
                'managed': False,
            },
        ),
        migrations.CreateModel(
            name='TRegions',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('regioncode', models.IntegerField(blank=True, db_column='RegionCode', null=True)),
                ('regionname', models.CharField(blank=True, db_column='RegionName', max_length=50, null=True)),
            ],
            options={
                'db_table': 't_Regions',
                'managed': False,
            },
        ),
        migrations.CreateModel(
            name='TStates',
            fields=[
                ('stateid', models.IntegerField(db_column='StateID', primary_key=True, serialize=False)),
                ('state', models.CharField(blank=True, db_column='State', max_length=255, null=True)),
                ('description', models.CharField(blank=True, db_column='Description', max_length=255, null=True)),
                ('hydrocode', models.IntegerField(blank=True, db_column='hydroCode', null=True)),
            ],
            options={
                'db_table': 't_States',
                'managed': False,
            },
        ),
        migrations.CreateModel(
            name='TSystems',
            fields=[
                ('systemid', models.IntegerField(db_column='SystemID', primary_key=True, serialize=False)),
                ('system', models.CharField(blank=True, db_column='System', max_length=255, null=True)),
                ('description', models.CharField(blank=True, db_column='Description', max_length=255, null=True)),
                ('defined_state', models.CharField(blank=True, db_column='Defined State', max_length=255, null=True)),
                ('examples', models.CharField(blank=True, db_column='Examples', max_length=255, null=True)),
                ('definedstateid', models.IntegerField(blank=True, db_column='DefinedStateID', null=True)),
                ('hydrocode', models.IntegerField(blank=True, db_column='hydroCode', null=True)),
                ('systemcategory', models.CharField(blank=True, db_column='SystemCategory', max_length=255, null=True)),
            ],
            options={
                'db_table': 't_Systems',
                'managed': False,
            },
        ),
        migrations.CreateModel(
            name='TTurbtypes',
            fields=[
                ('turbtypeid', models.FloatField(db_column='TurbTypeID', primary_key=True, serialize=False)),
                ('description', models.CharField(blank=True, db_column='Description', max_length=255, null=True)),
                ('mw', models.FloatField(blank=True, db_column='MW', null=True)),
            ],
            options={
                'db_table': 't_turbTypes',
                'managed': False,
            },
        ),
        migrations.CreateModel(
            name='TWoprnotes',
            fields=[
                ('siteid', models.IntegerField(db_column='SiteID', primary_key=True, serialize=False)),
                ('id', models.IntegerField(db_column='ID')),
                ('periodid', models.BigIntegerField(db_column='periodID')),
                ('username', models.CharField(db_column='Username', max_length=50)),
                ('note', models.CharField(db_column='Note', max_length=4000)),
                ('ts_utc', models.DateTimeField(blank=True, db_column='ts_UTC', null=True)),
                ('notificationid', models.IntegerField(blank=True, db_column='notificationID', null=True)),
            ],
            options={
                'db_table': 't_WOPRNotes',
                'managed': False,
            },
        ),
        migrations.AlterModelTable(
            name='tedits',
            table='t_Edits',
        ),
    ]
