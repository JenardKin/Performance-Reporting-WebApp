CREATE DATABASE WOPR
GO

USE [WOPR]
GO
/****** Object:  User [newLogin]    Script Date: 3/26/2019 2:53:55 PM ******/
CREATE USER [newLogin] FOR LOGIN [newLogin] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [newLogin]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [newLogin]
GO
/****** Object:  UserDefinedFunction [dbo].[GetDateTimeFromPeriodID]    Script Date: 3/26/2019 2:53:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetDateTimeFromPeriodID]
(
	@PeriodID bigint
)
RETURNS datetime
AS
BEGIN
	RETURN dateAdd(s, @PeriodID, '01 Jan 2000' )
END
GO
/****** Object:  UserDefinedFunction [dbo].[GetEventKeyFromDateTime]    Script Date: 3/26/2019 2:53:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[GetEventKeyFromDateTime]
(
	-- Add the parameters for the function here
	@ts datetime
)
RETURNS Bigint
AS
BEGIN
	
	-- Return the result of the function
	RETURN datediff (s, '01 Jan 2000', @ts)

END
GO
/****** Object:  UserDefinedFunction [dbo].[GetPeriodIDFromDateTime]    Script Date: 3/26/2019 2:53:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetPeriodIDFromDateTime]
(
	@ts datetime
)
RETURNS Bigint
AS
BEGIN
	declare @periodID as bigint
	
	set @periodID = (ceiling(datediff (s, '01 Jan 2000', @ts)/600.0))* 600
	
	
	if (datepart(millisecond, @ts) > 0 )
	
	begin
		set @periodID = (ceiling((datediff (s, '01 Jan 2000', @ts) + 1) /600.0))* 600
	end

	return @periodID
END
GO
/****** Object:  UserDefinedFunction [dbo].[GetTurbPivotStringBySite]    Script Date: 3/26/2019 2:53:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[GetTurbPivotStringBySite]
(
	@siteID int
)
RETURNS varchar(2000)
AS
BEGIN
	
		Declare @TurbString nvarchar(200)
		Declare @pivotHeaders nvarchar(2000)

		Set @pivotHeaders = ''

		DECLARE turb_cursor CURSOR FOR 
			SELECT '[' + Turbine + ']' 
			from t_SiteConfig where siteID = @siteID order by siteID, id

		OPEN turb_cursor

		FETCH NEXT FROM turb_cursor INTO @turbString

		WHILE @@FETCH_STATUS = 0
		BEGIN
			if len(@pivotHeaders) > 0 	Set @PivotHeaders = @PivotHeaders + ',' + @turbString
			else  Set @PivotHeaders = @PivotHeaders + @turbString
			
			FETCH NEXT FROM turb_cursor INTO @TurbString

		END 

		CLOSE turb_cursor
		DEALLOCATE turb_cursor
	RETURN @pivotHeaders
END
GO


/****** Object:  Table [dbo].[t_Circuits]    Script Date: 3/26/2019 2:53:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[t_Circuits](
	[CircuitID] [int] NOT NULL,
	[ID] [int] NOT NULL,
	[siteID] [int] NULL,
 CONSTRAINT [PK_t_Circuits] PRIMARY KEY CLUSTERED 
(
	[CircuitID] ASC,
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[t_EditFields]    Script Date: 3/26/2019 2:53:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[t_EditFields](
	[FieldID] [int] NOT NULL,
	[FieldName] [nvarchar](255) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[t_Edits]    Script Date: 3/26/2019 2:53:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[t_Edits](
	[EditID] [int] IDENTITY(1,1) NOT NULL,
	[ts_edit] [datetime] NOT NULL,
	[siteID] [int] NOT NULL,
	[id] [int] NOT NULL,
	[period_from] [int] NOT NULL,
	[period_to] [int] NOT NULL,
	[fieldID] [int] NOT NULL,
	[ts_EditStart] [datetime] NOT NULL,
	[ts_EditEnd] [datetime] NOT NULL,
	[username] [nvarchar](200) NOT NULL,
	[comment] [nvarchar](2000) NULL,
	[newVal] [int] NULL,
	[newValFloat] [float] NULL,
	[note] [nvarchar](2000) NULL,
	[groupID] [int] NULL,
	[newVal2] [int] NULL,
 CONSTRAINT [PK_t_Edits] PRIMARY KEY CLUSTERED 
(
	[EditID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[t_EnergyData]    Script Date: 3/26/2019 2:53:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[t_EnergyData](
	[siteID] [int] NOT NULL,
	[id] [int] NOT NULL,
	[ts] [datetime] NOT NULL,
	[periodID] [bigint] NOT NULL,
	[nws] [float] NULL,
	[kw_net] [float] NULL,
	[kw_exp] [float] NULL,
	[validFrom] [datetime] NOT NULL,
	[validTo] [datetime] NOT NULL,
	[kW_min_exp] [float] NULL,
	[curtailed] [tinyint] NOT NULL,
	[edited] [tinyint] NULL,
 CONSTRAINT [PK_t_EnergyData] PRIMARY KEY CLUSTERED 
(
	[siteID] ASC,
	[id] ASC,
	[periodID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[t_EventCodes]    Script Date: 3/26/2019 2:53:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[t_EventCodes](
	[EventID] [int] NOT NULL,
	[Description] [nvarchar](500) NULL,
	[DefaultStateID] [int] NOT NULL,
	[DefaultSystemID] [int] NOT NULL,
	[TurbTypeID] [int] NOT NULL,
	[ActionID] [int] NOT NULL,
	[EventLevel] [int] NOT NULL,
 CONSTRAINT [PK_t_EventCodes] PRIMARY KEY CLUSTERED 
(
	[EventID] ASC,
	[TurbTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[t_EventData]    Script Date: 3/26/2019 2:53:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[t_EventData](
	[SiteID] [int] NOT NULL,
	[ID] [int] NOT NULL,
	[ts_start] [datetime] NOT NULL,
	[EventID] [int] NOT NULL,
	[param1] [float] NULL,
	[param2] [float] NULL,
	[StateID] [int] NULL,
	[SystemID] [int] NULL,
	[ts_end] [datetime] NOT NULL,
	[periodID] [bigint] NOT NULL,
	[EventKey] [bigint] NOT NULL,
	[StateKey] [bigint] NULL,
	[SystemKey] [bigint] NULL,
	[ValidFrom] [datetime] NOT NULL,
	[ValidTo] [datetime] NOT NULL,
	[duration_ms] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[t_EventData_edited]    Script Date: 3/26/2019 2:53:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[t_EventData_edited](
	[SiteID] [int] NOT NULL,
	[ID] [int] NOT NULL,
	[ts_start] [datetime] NOT NULL,
	[EventID] [int] NOT NULL,
	[param1] [float] NULL,
	[param2] [float] NULL,
	[StateID] [int] NULL,
	[SystemID] [int] NULL,
	[ts_end] [datetime] NOT NULL,
	[periodID] [bigint] NOT NULL,
	[EventKey] [bigint] NOT NULL,
	[StateKey] [bigint] NULL,
	[SystemKey] [bigint] NULL,
	[ValidFrom] [datetime] NOT NULL,
	[ValidTo] [datetime] NOT NULL,
	[duration_ms] [int] NOT NULL,
 CONSTRAINT [PK_t_EventData_edited] PRIMARY KEY CLUSTERED 
(
	[SiteID] ASC,
	[ID] ASC,
	[periodID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[t_GroupMembers]    Script Date: 3/26/2019 2:53:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[t_GroupMembers](
	[GroupID] [int] NOT NULL,
	[ID] [int] NOT NULL,
	[siteid] [int] NULL,
 CONSTRAINT [PK_t_groupMembers] PRIMARY KEY CLUSTERED 
(
	[GroupID] ASC,
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[t_groups]    Script Date: 3/26/2019 2:53:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[t_groups](
	[GroupID] [int] NOT NULL,
	[SiteID] [int] NULL,
 CONSTRAINT [PK_t_groups] PRIMARY KEY CLUSTERED 
(
	[GroupID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[t_KKSNames]    Script Date: 3/26/2019 2:53:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[t_KKSNames](
	[KKS_Name] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](50) NULL,
 CONSTRAINT [PK_t_KKSNames] PRIMARY KEY CLUSTERED 
(
	[KKS_Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[t_powerCurves]    Script Date: 3/26/2019 2:53:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[t_powerCurves](
	[siteID] [int] NOT NULL,
	[id] [int] NOT NULL,
	[nws_bin] [decimal](5, 1) NOT NULL,
	[kW] [float] NULL,
	[kw_min] [float] NULL,
	[kw_max] [float] NULL,
	[kw_std] [float] NULL,
 CONSTRAINT [PK_t_powerCurves] PRIMARY KEY CLUSTERED 
(
	[siteID] ASC,
	[id] ASC,
	[nws_bin] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[t_Provinces]    Script Date: 3/26/2019 2:53:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[t_Provinces](
	[ProvinceID] [int] NULL,
	[Province] [nvarchar](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[t_Regions]    Script Date: 3/26/2019 2:53:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[t_Regions](
	[RegionCode] [int] NULL,
	[RegionName] [nvarchar](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[t_SiteConfig]    Script Date: 3/26/2019 2:53:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[t_SiteConfig](
	[siteID] [int] NOT NULL,
	[ID] [int] NOT NULL,
	[Turbine] [nvarchar](255) NOT NULL,
	[KKSName] [nvarchar](255) NOT NULL,
	[turbTypeID] [int] NOT NULL,
	[Pad] [int] NULL,
	[GearboxFrom] [datetime] NULL,
	[Gearbox Make] [nvarchar](255) NULL,
	[Gearbox Model] [nvarchar](255) NULL,
	[GeneratorFrom] [datetime] NULL,
	[Generator Make] [nvarchar](255) NULL,
	[Generator Model] [nvarchar](255) NULL,
	[nn1] [int] NULL,
	[nn2] [int] NULL,
	[IncludeInSiteTotals] [tinyint] NOT NULL,
	[MW] [decimal](18, 3) NULL,
 CONSTRAINT [PK_t_SiteConfig] PRIMARY KEY CLUSTERED 
(
	[siteID] ASC,
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[t_sites]    Script Date: 3/26/2019 2:53:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[t_sites](
	[SiteID] [int] NOT NULL,
	[Description] [nvarchar](100) NOT NULL,
	[doImportFlow] [int] NOT NULL,
	[DSNID] [int] NULL,
	[strWSTagName] [varchar](100) NULL,
	[strkWTagName] [varchar](100) NULL,
	[strEventTagName] [varchar](100) NULL,
	[strDSN] [varchar](100) NULL,
	[tz_offsetFromHistorian_h] [int] NOT NULL,
	[EventMod1000] [tinyint] NOT NULL,
	[strStatusTagName] [varchar](100) NULL,
	[nnSite1] [int] NULL,
	[nnSite2] [int] NULL,
	[AlbertaSMP] [tinyint] NULL,
	[GreenCreditStart] [datetime] NULL,
	[GreenCreditEnd] [datetime] NULL,
	[GreenCredit_cd] [float] NULL,
	[PPAEscalation] [varchar](200) NULL,
	[GreenCreditStartPeriod] [bigint] NULL,
	[GreenCreditEndPeriod] [bigint] NULL,
	[Power_in_MW] [tinyint] NULL,
	[importTimeOffset_h] [int] NULL,
	[Capacity_MW] [float] NULL,
	[JVRate] [float] NULL,
	[FinanceReportOrdering] [int] NULL,
 CONSTRAINT [PK_t_sites] PRIMARY KEY CLUSTERED 
(
	[SiteID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[t_States]    Script Date: 3/26/2019 2:53:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[t_States](
	[StateID] [int] NOT NULL,
	[State] [nvarchar](255) NULL,
	[Description] [nvarchar](255) NULL,
	[hydroCode] [int] NULL,
 CONSTRAINT [PK_t_states] PRIMARY KEY CLUSTERED 
(
	[StateID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[t_Systems]    Script Date: 3/26/2019 2:53:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[t_Systems](
	[SystemID] [int] NOT NULL,
	[System] [nvarchar](255) NULL,
	[Description] [nvarchar](255) NULL,
	[Defined State] [nvarchar](255) NULL,
	[Examples] [nvarchar](255) NULL,
	[DefinedStateID] [int] NULL,
	[hydroCode] [int] NULL,
	[SystemCategory] [nvarchar](255) NULL,
 CONSTRAINT [PK_t_Systems] PRIMARY KEY CLUSTERED 
(
	[SystemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[t_turbTypes]    Script Date: 3/26/2019 2:53:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[t_turbTypes](
	[TurbTypeID] [float] NOT NULL,
	[Description] [nvarchar](255) NULL,
	[MW] [float] NULL,
 CONSTRAINT [PK_t_turbTypes] PRIMARY KEY CLUSTERED 
(
	[TurbTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[t_WOPRNotes]    Script Date: 3/26/2019 2:53:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[t_WOPRNotes](
	[SiteID] [int] NOT NULL,
	[ID] [int] NOT NULL,
	[periodID] [bigint] NOT NULL,
	[Username] [nvarchar](50) NOT NULL,
	[Note] [nvarchar](4000) NOT NULL,
	[ts_UTC] [datetime] NULL,
	[notificationID] [int] NULL,
 CONSTRAINT [PK_t_WOPRNotes] PRIMARY KEY CLUSTERED 
(
	[SiteID] ASC,
	[ID] ASC,
	[periodID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[t_EnergyData] ADD  CONSTRAINT [DF_t_EnergyData_siteID]  DEFAULT ((0)) FOR [siteID]
GO
ALTER TABLE [dbo].[t_EnergyData] ADD  CONSTRAINT [DF_t_EnergyData_curtailed]  DEFAULT ((0)) FOR [curtailed]
GO
ALTER TABLE [dbo].[t_EnergyData] ADD  CONSTRAINT [DF_t_EnergyData_edited]  DEFAULT ((0)) FOR [edited]
GO
ALTER TABLE [dbo].[t_EventCodes] ADD  CONSTRAINT [DF_t_EventCodes_ActionID]  DEFAULT ((0)) FOR [ActionID]
GO
ALTER TABLE [dbo].[t_EventCodes] ADD  DEFAULT ((1)) FOR [EventLevel]
GO
ALTER TABLE [dbo].[t_SiteConfig] ADD  CONSTRAINT [DF_t_SiteConfig_IncludeInSiteTotals]  DEFAULT ((1)) FOR [IncludeInSiteTotals]
GO
ALTER TABLE [dbo].[t_sites] ADD  CONSTRAINT [DF_t_sites_doImportFlow]  DEFAULT ((0)) FOR [doImportFlow]
GO
ALTER TABLE [dbo].[t_sites] ADD  CONSTRAINT [DF_t_sites_tz_offsetFromHistorian_h]  DEFAULT ((0)) FOR [tz_offsetFromHistorian_h]
GO
ALTER TABLE [dbo].[t_sites] ADD  CONSTRAINT [DF_t_sites_FaultMod1000]  DEFAULT ((0)) FOR [EventMod1000]
GO
ALTER TABLE [dbo].[t_sites] ADD  DEFAULT ((0)) FOR [Power_in_MW]
GO
ALTER TABLE [dbo].[t_sites] ADD  DEFAULT ((2)) FOR [importTimeOffset_h]
GO
ALTER TABLE [dbo].[t_WOPRNotes] ADD  CONSTRAINT [DF_t_WOPRNotes_notificationID]  DEFAULT ((0)) FOR [notificationID]
GO

/****** Object:  StoredProcedure [dbo].[sp_AddWOPRNote]    Script Date: 3/26/2019 2:53:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_AddWOPRNote]
	-- Add the parameters for the stored procedure here
	@siteID int, @turbine varchar(100), @ts datetime, 
	@strUserName nvarchar(100), @strNote nvarchar(2000) = ''

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT Systemments.
	SET NOCOUNT ON;

	Declare @queryTime datetime 
	Declare @periodID bigint
	Declare @TurbID int
	
	Set @queryTime = getUTCDate() 
	Set @turbID = null
	
	-- need some data validation here. in case these are no good.
	select @turbID = id from t_siteConfig where [turbine] = @turbine and siteID = @siteID
	
	if @turbID is null 
	Begin
		select 'Bad turbine id passed: ' + @turbine + 'Not adding note'
		return -1
	end


	if @strUserName is null 
	Begin
		select 'Bad username passed: ' + @strUserName
		return -1
	end
	
	if  (isDate(@ts) = 0 or @ts < '2012-01-01') 
	begin
		select 'Bad date passed: ' + cast (@ts as varchar(100))
		return -1
	end
		
	set @periodID = dbo.GetPeriodIDFromDateTime (dbo.getDBTimeStampFromLocal(@siteID, @ts)) -- remember that the editStartTime is the tail end of the period.
	
	insert into [dbo].[t_WOPRNotes] (siteID, id, periodID, UserName, Note, ts_UTC) values
	(@siteID, @turbID, @PeriodID, @strUserName, @strNote, @queryTime)
	
select 'Added note for Turbine ' + @turbine

return 0


END





GO
/****** Object:  StoredProcedure [dbo].[sp_GetEventsCountorDowntime]    Script Date: 3/26/2019 2:53:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetEventsCountorDowntime]
	-- Add the parameters for the stored procedure here
	@siteID int, @startTime datetime, @endTime datetime, @doDowntime integer, @doByMonth integer
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	Declare @strSQL nvarchar(2000), @pivotHeaders nvarchar (2000)
	Declare @parmdefinition nvarchar (1000)
	
	declare @period_start bigint
	declare @period_end bigint
	declare @turbTypeID integer
	declare @aggregateString nvarchar(2000)
	declare @groupTimeString nvarchar(2000)
	declare @groupBy nvarchar(2000)
	declare @joinToSiteConfig nvarchar (2000)
	declare @tz_offset integer
	declare @selectString1 nvarchar (2000)
	declare @selectString2 nvarchar (2000)
	declare @selectString3 nvarchar (2000)
	
	set @tz_offset = 0
	
	select @tz_offset = tz_offsetFromHistorian_h from t_sites where siteID = @siteID

	if @doByMonth = 1
	begin
		set @pivotHeaders = dbo.GetMonthPivotStringFromDates(@startTime, @endTime)
		set @groupBy = ' group by siteID, eventID, eventKey, datepart(Year, dateAdd(hour, ' 
			+ cast (@tz_offset as varchar (10)) + ', ts_start)), datepart(Month, dateAdd(hour, ' 
			+ cast (@tz_offset as varchar (10)) + ', ts_start)) '
		set @joinToSiteConfig =  ' '
		set @selectString1 = 'dbo.GetTimeStringFromYearAndMonth( datepart(Year, dateAdd(hour, ' 
			+ cast (@tz_offset as varchar (10)) + ', ts_start)) , datepart(Month, dateAdd(hour, ' 
			+ cast (@tz_offset as varchar (10)) + ', ts_start)) ) as id '
		set @selectString2 = 'id as groupParam '
	end
	else
	begin	
		set @pivotHeaders = dbo.GetTurbPivotStringBySite(@siteID)
		set @groupBy = ' group by siteID, id, eventID, eventKey '
		set @joinToSiteConfig = ' inner join siteConfig on siteConfig.siteID = a.siteID and siteConfig.id = a.id '
		set @selectString1 = ' id '
		set @selectString2 = 'Turbine as groupParam '
	end
	
	Set @parmDefinition =  N'@PeriodStartSP bigint, @PeriodEndSP bigint, 
			@siteIDSP int, @turbTypeSP int';

	if len(@pivotHeaders) < 2 
	begin 
		print 'invalid site ID, no pivot headers' + cast (@SiteID as varchar(10))
		return
	end

	if dateDiff (day, @startTime, @endTime) > 366 begin
		print 'start and end date ranges too big.  allow 1 year max'
		set @endTime = dateAdd (year, 1, @startTime)
	end	


	set @period_start = dbo.getPeriodIDFromDateTime(dbo.getDBTimeStampFromLocal(@siteID, @startTime))
	set @period_end = dbo.getPeriodIDFromDateTime(dbo.getDBTimeStampFromLocal(@siteID, @endTime))


	Select @turbTypeID = min(turbTypeID) from t_siteConfig where siteID = @siteID

	
	if @doDowntime = 1 
	begin
		set @aggregateString =  ' sum(duration_h) as eventInfo '
		set @groupTimeString = ', sum(duration_ms/1000.0)/3600.0 as duration_h '
	end
	else 
	begin
		set @aggregateString =  ' count(*) as eventInfo '
		set @groupTimeString = ' '
	end
	
	set @strSQL = N'select  * from 
		(
			select ' + @SelectString2 + ', a.eventID, Description, eventInfo from
			(
				select siteID, eventID, id, ' + @aggregateString  
				+ ' from 
					(
					select siteID, ' + @SelectString1 + ', eventID, eventKey ' + @groupTimeString
					+ ' from
					t_eventData 
					where siteID = @siteIDSP
					and periodID between @PeriodStartSP and @PeriodEndSP
					' + @groupBy + '
					) as ev
				group by siteID, id, eventID
				) as a
			inner join 
			t_eventCodes on t_eventCodes.eventID = a.eventID ' + @joinToSiteConfig 
			+ ' where t_eventCodes.turbTypeID = @turbTypeSP
			and defaultSystemID <> 0
			and a.eventID <> 11000
		
	
		) as sourceData
		pivot (
		sum(eventInfo)
		for groupParam in 
		(' + @PivotHeaders + ')
		) as pvt
		order by eventID'
			
	print @strSQL 

	exec sp_executeSQL @strSQL, @parmDefinition, 
		@PeriodStartSP = @Period_Start, 
		@PeriodEndSP = @Period_End, 
		@siteIDSP = @siteID,
		@turbTypeSP  = @turbTypeID;




END





GO
/****** Object:  StoredProcedure [dbo].[sp_GetLostProductionCrosstab]    Script Date: 3/26/2019 2:53:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetLostProductionCrosstab]
	-- 2017-06-05:  Modified to accept groupID.
	@siteID int, @startTime datetime, @endTime datetime, @groupID integer = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	Declare @queryTime datetime
	Declare @strSQL nvarchar(2000), @pivotHeaders nvarchar (2000)
	Declare @parmdefinition nvarchar (1000)
	Declare @periodStart as bigint, @periodEnd as bigint
	Declare @testGroupCount int
	Set @queryTime = getDate()


		
-- 2017-06-05:  Handle if a groupID is passed.
-- Check whether there is a valid groupID for the given siteID. If not, set groupID to zero.
	if (@groupID > 0) 
	Begin

		select @testGroupCount = isNull(count(*), 0) from t_groupMembers where groupID = @groupID
		if @testGroupCount = 0
		begin
			set @groupID = 0
		end
		select @siteID = min(siteid) from t_groupMembers where GroupID = @groupID
		-- set the pivot headers for the group.
		set @pivotHeaders = dbo.GetTurbPivotStringBySiteAndGroup(@siteID, @groupID)
	end
	else
	begin
		set @pivotHeaders = dbo.GetTurbPivotStringBySite(@siteID)

	end


	-- do the time zone offset here!!!
	

	set @periodStart = dbo.GetPeriodIDFromdateTime (dbo.GetDBTimeStampFromLocal(@siteID, @startTime)); 
	set @periodEnd = dbo.GetPeriodIDFromDateTime (dbo.GetDBTimeStampFromLocal(@siteID, @endTime)); 
	-- not doing tz offset to start and end time.



	


	-- 2017-06-05:  added groupID
	Set @parmDefinition =  N'@periodStartSP bigInt, @periodEndSP bigInt, 
			@siteIDSP int, @groupIDSP int';

	if len(@pivotHeaders) < 2 
	begin 
		print 'invalid site ID, no pivot headers' + cast (@SiteID as varchar(10))
		return
	end

	if dateDiff (day, @startTime, @endTime) > 600 begin
		print 'start and end date ranges too big.  allow 1 year max'
		set @endTime = dateAdd (year, 1, @startTime)
	end	
	



	-- for a 10-min event with multiple events, select based on 
	--	(1) dt not zero - takes priority (even null), 
	--	(2) then whatever is the longest period of events.

	set @strSQL = N'select * from ( select [state], [system], [turbine], MWhLost from ( select stateID, systemID, id, siteID, 
sum(kwhLost)/1000.0 as MWhLost from ( select t_EventData.stateID, t_EventData.systemID, t_EventData.ID, t_EventData.siteID, (kw_exp - isNull(kw_net,0))/6.0 as kWhLost, 
Rank() over (partition by t_EventData.id, t_EventData.periodID order by case when t_EventData.stateID = 0 then 1 else 0 end, case when t_EventData.systemID = 0 then 1 else 0 end, 
duration_ms desc, ts_start) as R from t_EventData  
inner join t_energydata as t on t.siteID = t_EventData.siteID and t.periodID = t_EventData.periodID and t.ID = t_EventData.ID '

if (@groupID > 0) 
	begin
		set @strSQL = @strSQL + N' inner join t_groupMembers on t_eventData.siteID = t_groupMembers.siteID and t_eventData.id = t_groupMembers.id '
--	 	set @strSQL = @strSQL + N' where t_EventData.siteID = @siteIDSP and t_EventData.periodID > @periodStartSP and t_EventData.periodID <= @periodEndSP '
	 	set @strSQL = @strSQL + N' where t_EventData.periodID > @periodStartSP and t_EventData.periodID <= @periodEndSP '
		set @strSQL = @strSQL + N' and groupID = @groupIDSP '

	end
else
begin -- no groupID - the normal case!

	set @strSQL = @strSQL + N' where t_EventData.siteID = @siteIDSP and t_EventData.periodID > @periodStartSP and t_EventData.periodID <= @periodEndSP '
end
/* -- 2018-02:  Moved to the if block above.
if (@groupID > 0) 
	begin
		set @strSQL = @strSQL + N' and groupID = @groupIDSP '
	end
*/
	
	set @strSQL = @strSQL + N') as a 
where a.R = 1 group by siteID, id, stateID, systemID ) as b 
inner join siteConfig on b.siteID = siteConfig.siteID and b.id = siteConfig.id 
inner join t_states on b.stateID = t_states.stateID inner join t_systems on b.systemID = t_systems.systemID ) as sourcedata pivot(sum (MWhLost) 
		for turbine in 
		(' + @PivotHeaders + ')
		) as pvt
 order by [state], [system]'
			
	print @strSQL 

	exec sp_executeSQL @strSQL, @parmDefinition, 
		@periodStartSP = @periodStart, 
		@periodEndSP = @periodEnd, 
		@siteIDSP = @siteID, 
		@groupIDSP = @groupID;




END





GO
/****** Object:  StoredProcedure [dbo].[sp_UpdateState]    Script Date: 3/26/2019 2:53:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- MOdified 2012-10-01 to not check the validFrom/ValidTo dates, and to use UTC for the @queryTime
-- Modified 2013-01-09 to not check ValidFrom/ValidTo dates in the "subsequent event key", 
--   and to fix the ts_for reporting to check siteID, id when finding future state keys (was very slow),
--   and to output more time (ms) diagnostics.
-- =============================================
CREATE PROCEDURE [dbo].[sp_UpdateState]
	-- Add the parameters for the stored procedure here
	@siteID int, @turbine varchar(100), @EditstartTime datetime, @EditendTime datetime, 
	@newState varchar(100), @strUserName varchar(100), @strNote varchar(1000) = ''

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @queryTime datetime 
	Declare @periodStart bigint, @periodEnd bigInt
	Declare @TurbID int
	Declare @turbTypeID int
	Declare @NewStateID int
	Declare @firstKey bigint, @lastKey bigint
	Declare @firstKey_startTS datetime, @firstKey_endTS dateTime
	Declare @lastKey_startTS datetime, @lastKey_endTS dateTime
	Declare @ts_editStart dateTime, @ts_editEnd datetime
	Declare @subsequentStateID integer, @subsequentStateKey bigint
	Declare @PrevStateID integer, @PrevStateKey bigint
	Declare @newStateKey bigint, @newSubsequentStateKey bigInt
	Declare @timerStart datetime, @timerEnd dateTime, @ms_elapsed int
	Declare @editFieldID integer
	Declare @tz_offset_h integer


	select @editFieldID = FieldID from t_editFields where lower(FieldName) = lower('State')

	select @tz_offset_h = tz_offsetFromHistorian_h from t_sites where siteID = @siteID
	set @EditstartTime = dateAdd(hour, -1 * @tz_offset_h, @EditstartTime)
	set @EditEndTime = dateAdd(hour, -1 * @tz_offset_h, @EditEndTime)

	Set @queryTime = getUTCDate() 
	Set @turbTypeID = null
	Set @turbID = null
	Set @newStateID = null
	
	
	-- need some data validation here. in case these are no good.
	--select @turbID = id from siteConfig where [turbine] = @turbine and siteID = @siteID
	select @turbID = id, @turbTypeID = turbTypeID from t_siteConfig where [turbine] = @turbine and siteID = @siteID
	select @newstateID = stateID from t_states where [state] = @newState

	if @turbID is null 
	Begin
		print 'Bad turbine id passed: ' + @turbine
		return -1
	end

	

	if @newStateID is null and @turbTypeID = 18
	begin
		Begin
			select @newstateID = stateID from t_Hydrostates where [state] = @newState
		end
	end
	

	if @newStateID is null 
	Begin
		print 'Bad stateid passed: ' + @newState
		return -1
	end

	print 'Edited turbID: ' + cast (@turbID as varchar(10)) + ' passed: ' + @turbine

	set @periodStart = dbo.GetPeriodIDFromDateTime (@EditstartTime) -- remember that the editStartTime is the tail end of the period.
	set @periodEnd = dbo.GetPeriodIDFromDateTime(@EditendTime)

	print 'Query time ' + cast (@queryTime as varchar(100))
	print 'Requested EditStartTime ' + cast (@EditStartTime as varchar(100))
	print 'Requested EditEndTime ' + cast (@EditEndTime as varchar(100))
	print 'Period start:' + cast (@periodStart	 as varchar(100))
	print 'Period end:' + cast (@periodEnd	 as varchar(100))
	
--------------------------------------------------------------
-- Create a temporary table for the inserts.
-- Should be a copy of t_EventData - update when t_EventData changes!
--------------------------------------------------------------

declare @tt_events TABLE ([SiteID] [int],	[ID] [int],	[ts_start] [datetime],
	[EventID] [int],	[param1] [float],	[param2] [float],	[StateID] [int],
	[SystemID] [int],	[ts_end] [datetime],	[periodID] [bigint],	[EventKey] [bigint],
	[StateKey] [bigint],	[SystemKey] [bigint],	[ValidFrom] [datetime],
	[ValidTo] [datetime],	[duration_ms] [int], [R] [int])


print 'initial insert into edit table, including 1 overhanging record.: '

Set @timerStart = current_timestamp

insert into @tt_events(SiteID,ID,ts_start,EventID,param1,param2,StateID,
	SystemID,ts_end,periodID,
	EventKey,StateKey,SystemKey,ValidFrom,ValidTo,duration_ms)
select
	SiteID,ID,ts_start,EventID,param1,param2,StateID,
	SystemID,ts_end,periodID,
	EventKey,StateKey,SystemKey,ValidFrom,ValidTo,duration_ms
from t_EventData
		where siteID = @siteID
		and id = @turbID
		and periodID between @periodStart-600 and @periodEnd+600
		--and validFrom <= @queryTime and ValidTo > @queryTime

set @timerEnd = current_timestamp
set @ms_elapsed = datediff(millisecond, @timerStart, @timerEnd)
print 'time (ms):' + cast (@ms_elapsed as varchar(100))

--- find first and last keys - determine if I need to edit these.
	select top 1 @firstKey = stateKey 
		from @tt_events where periodID = @periodStart order by ts_start

	select top 1 @lastKey = stateKey
		from @tt_events where periodID = @periodEnd	order by ts_start desc

	print 'First Key: ' + cast (@firstKey as varchar(100))
	print 'Last Key: ' + cast (@lastKey as varchar(100))

-----------------------------------------------------------------------------------
-- Update the rank in the @tt_events table
-- Actually, the whole table doesn't need to be edited - could change.
-----------------------------------------------------------------------------------

print 'Setting rank:'
Set @timerStart = current_timestamp

	update @tt_events set t.R = DisplayRank
	from @tt_events as t inner join 
	(	
		select siteID, id, periodID, ts_start, Rank() 
			over (partition by siteid, id, periodID 
			order by case when stateID = 0 then 1 else 0 end, 
			duration_ms desc, ts_start) as DisplayRank
		from @tt_events as b
		where (periodID between @periodStart-600 and @periodStart
			or periodID between @periodEnd and @periodEnd+600)

	)  as a
	on t.siteID = a.siteID and t.id = a.id and t.PeriodID = a.PeriodID and t.ts_start = a.ts_start

set @timerEnd = current_timestamp
set @ms_elapsed = datediff(millisecond, @timerStart, @timerEnd)
print 'time (ms) for setting rank:' + cast (@ms_elapsed as varchar(100))
Set @timerStart = current_timestamp


-------------------------------------------------------------------
-- Start and end times of the first and last keys

	select @firstKey_startTS = min(ts_start), @firstKey_endTS = max(ts_end) 
		from @tt_events
		where stateKey = @firstKey		

	select @lastKey_startTS = min(ts_start), @lastKey_endTS = max(ts_end)
		from @tt_events 
		where stateKey = @lastKey		

-------------------------------------------------------------------
-- Rank of the first and last keys in the first and last periods of the edit, plus the prev and subsequent ones.

	Declare @FirstKeyRankPrev integer, @firstKeyRankFirst  integer
	Declare @lastKeyRankLast integer, @lastKeyRankSubsequent integer

	Set @FirstKeyRankPrev = NULL -- This should make 
	Set @FirstKeyRankFirst = null
	Set @lastKeyRankLast = null
	Set @lastKeyRankSubsequent = null


	select @FirstKeyRankPrev = R from @tt_events where periodID = @periodStart-600 and stateKey = @firstKey		
	select @FirstKeyRankFirst = R from @tt_events where periodID = @periodStart and stateKey = @firstKey		
	select @LastKeyRankLast = R from @tt_events where periodID = @periodEnd and stateKey = @LastKey		
	select @LastKeyRankSubsequent = R from @tt_events where periodID = @periodEnd + 600 and stateKey = @LastKey		
	
	set @firstKeyRankPrev = isNull(@firstKeyRankPrev, 100)
	set @firstKeyRankFirst = isNull(@firstKeyRankFirst, 100)
	set @LastKeyRankLast = isNull(@LastKeyRankLast, 100)
	set @LastKeyRankSubsequent = isNull(@LastKeyRankSubsequent, 100)

	print 'FirstKey ' + cast (@firstKey as varchar(10))

	print 'FirstKeyRankPrev ' + cast (@firstKeyRankPrev as varchar(10))
	print 'FirstKeyRankFirst ' + cast (@firstKeyRankFirst as varchar(10))
	print 'FirstKeyRankLast ' + cast (@LastKeyRankLast as varchar(10))
	print 'FirstKeyRankSubsequent ' + cast (@LastKeyRankSubsequent as varchar(10))

-- Decide whether or not to edit the event labelled with firstKey.--------------------------------

	set @ts_editStart = dbo.GetDateTimeFromPeriodID (@periodStart-600) 
	print 'ts_editStart: ' + cast(@ts_editSTart as varchar(100))

	if @firstKey_EndTS < @editStartTime -- FirstKey event ends in first period:
		Begin
			print 'First key ends in first period'
		
			if (@firstKeyRankFirst <> 1 and @firstKeyRankPrev = 1)	-- You don't see it in the first period but see it in the prev - don't edit.
			begin
				
				set @ts_editStart = @firstKey_EndTS		
			end
		End
	else -- FirstKey extends beyond the first period.  Check whether to edit any of the previous periods.
		begin
			if (dateDiff(second, @firstKey_startTS, dbo.GetDateTimeFromPeriodID(@periodStart)) < 1200 
				and @firstKeyRankPrev <> 1 ) -- the state starts in the previous Period and you wouldn't see it in the prev period:
				begin
					set @ts_editStart = @firstKey_startTS
				end
		end 

	print 'ts_editStart (new!): ' + cast(@ts_editSTart as varchar(100))


set @timerEnd = current_timestamp
set @ms_elapsed = datediff(millisecond, @timerStart, @timerEnd)
print 'time (ms) for deciding about FirstKey event:' + cast (@ms_elapsed as varchar(100))
Set @timerStart = current_timestamp	

-- Decide whether or not to edit the event labelled with lastKey.--------------------------------

	set @ts_editEnd = dbo.GetDateTimeFromPeriodID (@periodEnd)
	print 'ts_editEnd: ' + cast(@ts_editEnd as varchar(100))

	if @LastKey_StartTS > dbo.GetDateTimeFromPeriodID(@periodEnd-600) -- LastKey starts during the last period.  Check whether to include.
	Begin
		if (@LastKeyRankLast <> 1 and @lastKeyRankSubsequent = 1)
		begin	
			set @ts_editEnd = @lastKey_StartTS
		end
	end
	else -- LastKey starts prior to the last period.  Decide whether to extend to the subsequent periods.
	begin 
		if (dateDiff(second, dbo.GetDateTimeFromPeriodID(@periodEnd), @LastKey_EndTS) < 600
			and @lastKeyRankSubsequent <> 1) 
			begin
				set @ts_editEnd = @lastKey_EndTS
			End
	end

	print 'ts_editEnd (new): ' + cast(@ts_editEnd as varchar(100))

set @timerEnd = current_timestamp
set @ms_elapsed = datediff(millisecond, @timerStart, @timerEnd)
print 'time (ms) for deciding about LastKey event:' + cast (@ms_elapsed as varchar(100))
Set @timerStart = current_timestamp	
-----------------------------------------------------------------------------------------
-- Chop the temporary event table at ts_editStart and ts_editEnd.
	print 'Deleting beyond editStart and editEnd'
	delete from @tt_events where ts_start < @ts_editStart or ts_start >= @ts_editEnd

-----------------------------------------------------------------------------------------
-- Update the temporary event table.

	print 'Updating the temp table with the new events!'
	update @tt_events set stateID = @newStateID 
		where ts_start >= @ts_editStart and ts_start < @ts_editEnd

-------------------------------------------------------------------------------------------------------------------
-- Update the Valid Dates!!!
-------------------------------------------------------------------------------------------------------------------

 Update @tt_events set ValidFrom = @queryTime, ValidTo = '2100-01-01'

-----------------------------------------------------------------------------------------
-- Update the StateKey for the edited records.
-----------------------------------------------------------------------------------------

	set @prevStateID = null
	set @prevStateKey = null

	select @prevStateID = StateID, @prevStateKey = StateKey
		from t_eventData 
		where siteID = @siteID
		and id = @turbID
		and periodID between @periodStart-600 and @periodStart -- in the prev or first records.
		and validFrom <= @queryTime and ValidTo > @queryTime
		and ts_end = @ts_editStart

	print 'Previous state and key: ' + cast (@prevStateID as varchar(100)) + ' , ' +  cast(@prevStateKey as varchar(100))

	if @prevStateID = @NewStateId -- editing to make it the same ... will have to set the state key to be PrevStateKey.
		Begin
			set @newStateKey = @prevStateKey 
		end
	else -- editing to make it different.  I think that this would handle a null prevStateKey.
		Begin
			set @newStateKey = dbo.GetEventKeyFromDateTime(@ts_EditStart)			
		end

	Update @tt_events set StateKey = @newStateKey



set @timerEnd = current_timestamp
set @ms_elapsed = datediff(millisecond, @timerStart, @timerEnd)
print 'time (ms) for updating @tt_events:' + cast (@ms_elapsed as varchar(100))
Set @timerStart = current_timestamp	
-----------------------------------------------------------------------------------------
-- Check for change of key at end ...
-- Note: @subsequentStateKey and @newSubsequentStateKey are used for the edits within the transaction!!
-----------------------------------------------------------------------------------------

	set @subsequentStateID = null
	set @subsequentStateKey = null
	set @NewsubsequentStateKey = -1 -- This will be used to test whether to update the state keys after the edit.

	select @SubsequentStateID = StateID,  @SubsequentStateKey = StateKey
		from t_eventData 
		where siteID = @siteID
		and id = @turbID
		and periodID between @periodEnd and @periodEnd + 600 -- in the prev or first records.
		--and validFrom <= @queryTime and ValidTo > @queryTime
		and ts_start = @ts_editEnd

	if (@subsequentStateKey is not null)  -- means there is some following data.
	Begin
		if @subsequentStateID = @newStateID 
			set @newSubsequentStateKey = @newStateKey -- same	
		else if @subsequentStateKey <> dbo.GetEventKeyFromDateTime (@ts_editEnd) 
			set @newSubsequentStateKey = dbo.GetEventKeyFromDateTime (@ts_editEnd)
	End
	else 
		print 'subsequent state ID is null, not examining subsequent state keys!'


		print 'subsequent state key: ' + cast (@SubsequentStateKey as varchar(10))
		print 'new state key: ' + cast (@newSubsequentStateKey as varchar(10))


	Declare @ts_forReporting datetime

	if @newSubsequentStateKey > 0
	begin
		select @ts_forReporting =  min(ts_start) from t_eventData where stateKey = @subsequentStateKey and ts_start >= @ts_editEnd
			and siteID = @siteID and id = @turbID and periodID >= @periodEnd
		print 'updating records from ' + cast (@ts_forReporting as varchar(100))
		select @ts_forReporting = max(ts_end) from t_eventData where stateKey = @subsequentStateKey  and ts_start >= @ts_editEnd
			and siteID = @siteID and id = @turbID and periodID >= @periodEnd
		print 'updating records to ' + cast (@ts_forReporting as varchar(100))
		print 'with new state key: ' + + cast (@newSubsequentStateKey as varchar(10))
	end


set @timerEnd = current_timestamp
set @ms_elapsed = datediff(millisecond, @timerStart, @timerEnd)
print 'time (ms) for checking for change of key at end:' + cast (@ms_elapsed as varchar(100))
Set @timerStart = current_timestamp
/*	-- If the period after the edit isn't the same as the new edited value, give it a new start TS.
	update @tt_events set stateKey = dbo.GetEventKeyFromDateTime(@ts_EditEnd)
		where ts_start >= @ts_editEnd and stateID <> @newStateID
*/

    BEGIN TRY 
        BEGIN TRANSACTION 
        
Set @timerStart = current_timestamp


------------------------------------------------------------------------------------------
-- Record the edit.
------------------------------------------------------------------------------------------

    insert into t_edits(siteID, id, ts_editStart, ts_editEnd, ts_edit, fieldID, UserName, 
			comment, Period_From, Period_To, newVal)
		values (@siteID, @turbID, @ts_editStart, @ts_editEnd, @queryTime, @editFieldID, @strUserName, 
		'Set State = ' + @NewState + ' for Turbine ' + @turbine, @PeriodStart, @periodEnd, @newSTateID)

------------------------------------------------------------------------------------------
-- Copy the edited data to the t_events_edited table.
------------------------------------------------------------------------------------------

	insert into t_eventData_edited(SiteID,ID,ts_start,EventID,param1,param2,StateID,
			SystemID,ts_end,periodID, EventKey,StateKey,SystemKey,ValidFrom,ValidTo,duration_ms)
	select
		t_EventData.SiteID,t_EventData.ID,t_EventData.ts_start,t_EventData.EventID,t_EventData.param1,
		t_EventData.param2,t_EventData.StateID, t_EventData.SystemID,t_EventData.ts_end,t_EventData.periodID,
		t_EventData.EventKey,t_EventData.StateKey,t_EventData.SystemKey,t_EventData.ValidFrom,
		@queryTime as ValidTo, -- Remember to set this one!
		t_EventData.duration_ms
	from t_EventData
		inner join @tt_events as j
			on t_eventData.SiteID = j.SiteID
			and t_eventData.id = j.ID
			and t_eventData.PeriodID = j.PeriodID
			and t_eventData.ts_start = j.ts_start
	--where t_eventData.validFrom <= @queryTime and t_eventData.ValidTo > @queryTime -- This "where" not necessary anymore.

------------------------------------------------------------------------------------------
-- Update the t_eventData table
------------------------------------------------------------------------------------------

	update t_EventData set t_EventData.StateID = j.StateID, 
		t_eventData.StateKey = j.StateKey,
		t_EventData.ValidFrom = j.ValidFrom,
		t_EventData.ValidTo = j.ValidTo
	from t_EventData
		inner join @tt_events as j
			on t_eventData.SiteID = j.SiteID
			and t_eventData.id = j.ID
			and t_eventData.PeriodID = j.PeriodID
			and t_eventData.ts_start = j.ts_start
	--where t_eventData.validFrom <= @queryTime and t_eventData.ValidTo > @queryTime -- This "where" not necessary anymore.


--------------------------------------------
-- Update new subsequent state keys.
--------------------------------------------

	if @newSubsequentStateKey > 0 
	Begin
		update t_eventData set stateKey = @newSubsequentStateKey where stateKey = @subsequentStateKey and ts_start >= @ts_editEnd
			and siteID = @siteID and id = @TurbID
	end


set @timerEnd = current_timestamp
set @ms_elapsed = datediff(millisecond, @timerStart, @timerEnd)
print 'time (ms) for items within transaction:' + cast (@ms_elapsed as varchar(100))

--------------------------------------------
-- Do the transaction
--------------------------------------------


Set @timerStart = current_timestamp
        
	--ROLLBACK TRANSACTION
      COMMIT TRANSACTION  -- do the transaction!


set @timerEnd = current_timestamp
set @ms_elapsed = datediff(millisecond, @timerStart, @timerEnd)
print 'time (ms) to commit transaction:' + cast (@ms_elapsed as varchar(100))
	
    END TRY 

    BEGIN CATCH 
      
        ROLLBACK TRANSACTION
		print 'Edit not committed'
		PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR); 
        PRINT 'Error Message: ' + ERROR_MESSAGE(); 
        PRINT 'Error Severity: ' + CAST(ERROR_SEVERITY() AS VARCHAR); 
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS VARCHAR); 
        PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR); 
        PRINT 'Error Proc: ' + ERROR_PROCEDURE(); 
        RETURN ERROR_NUMBER(); 
       
    END CATCH 

--select * from @tt_events order by ts_start
select 'Set State = ' + @NewState + ' for Turbine ' + @turbine

return 0


END


/*
insert into t_eventCodes (eventID, description, defaultstateID, defaultSystemID,turbTypeID)
values (223, 'Stop', 2, 672, 1)

insert into t_eventCodes (eventID, description, defaultstateID, defaultSystemID,turbTypeID)
values (430, 'Transmission Oscillation __ RPM, __ m/s', 2, 668, 1)

*/

GO
/****** Object:  StoredProcedure [dbo].[sp_UpdateStateSystemWhereCTH]    Script Date: 3/26/2019 2:53:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_UpdateStateSystemWhereCTH]
	-- Add the parameters for the stored procedure here
		@siteID int, 
		@groupID int,
		@EditstartTime datetime, 
		@EditendTime datetime, 
		@newState varchar(100), 
		@newSystem varchar(100), 
		@strUserName varchar(100), 
		@strNote varchar(1000), 
		@exactStartTime int = 0

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT Systemments.
	SET NOCOUNT ON;

	Declare @queryTime datetime 
	Declare @periodStart bigint, @periodEnd bigInt
	Declare @TurbID int	
	Declare @timerStart datetime, @timerEnd dateTime, @ms_elapsed int
	Declare @editFieldID integer
	Declare @tz_offset_h integer
	declare @ts_startKey datetime
	declare @updateKeyFrom datetime
	declare @updateKeyTo datetime
	declare @newKey bigint
	Declare @newStateID integer 
	Declare @newSystemID integer
	Declare @isValidGroup integer
	Declare @isValidSiteID integer
	

	-----------------------------------------------------
	-- Check for a valid groupID.  
	-- if there is one, using that.
	-- if not, set groupID = 0 to use the siteID.
	-----------------------------------------------------
	
	if (@groupID is null or @groupID = 0) 
	Begin
		print 'Bad GroupID passed: ' + cast(isNull(@groupID, 0) as varchar(10))
		print 'Using SiteID'
		set @groupID = 0
	end
	
	select @isValidGroup = count(*) from t_groups where groupID = @groupID
	
	if (@isValidGroup < 1) 
	Begin
		set @GroupID = 0
		select @isValidSiteID = count(*) from t_sites where siteID = @SiteID
		if (@isValidSiteID < 1) 
		Begin
			print 'Bad Site and groupID passed: ' 
				+ cast(isNull(@siteID, 0) as varchar(10)) 
				+ ', ' + cast(isNull(@groupID, 0) as varchar(10))
			return -1	
		
		End 
	
	
	End
	

	
	-----------------------------------------------------
	-- We're using a groupID - select the siteID based on the groupID.
	-----------------------------------------------------
	if (@isValidGroup > 0) Begin
		select @siteID = min(siteID) from t_GroupMembers where GroupID = @GroupID
	end
	

	-----------------------------------------------------
	-- Check for a valid State and system.
	-----------------------------------------------------
	
	select @newStateID = StateID from t_States where [State] = @newState
	if @newStateID is null 
	Begin
		print 'Bad Stateid passed: ' + @newState
		return -1
	end

	select @newSystemID = SystemID from t_Systems where [Description] = @newSystem -- NOTE: 190325-STEVE: I changed it to Description from System.
	if @newSystemID is null 
	Begin
		print 'Bad systemid passed: ' + @newSystem
		return -1
	end


	
	select @editFieldID = FieldID from t_EditFields where lower(FieldName) = lower('State and System')

	select @tz_offset_h = tz_offsetFromHistorian_h from t_sites where siteID = @siteID
	set @EditstartTime = dateAdd(hour, -1 * @tz_offset_h, @EditstartTime)
	set @EditEndTime = dateAdd(hour, -1 * @tz_offset_h, @EditEndTime)
	
	-- remember that right now we're assuming the editStartTime is the tail end of the period, might need to change.
	set @periodStart = dbo.GetPeriodIDFromDateTime (@EditstartTime) 
	
	-- 2014-12-11:  If someonepasses exactstartTime = 1, check if the edit starts on a period boundary.  If so, increase the periodID.
	if (@ExactStartTime <> 0) 
	begin
		if dbo.getEventKeyFromDateTime(@editStartTime) = dbo.getPeriodIDFromDateTime(@editStartTime)
		begin
			set @periodStart = @periodStart + 600	
		end
	end
	-- 
	set @periodEnd = dbo.GetPeriodIDFromDateTime(@EditendTime)

	print 'Requested EditStartTime ' + cast (@EditStartTime as varchar(100))
	print 'Requested EditEndTime ' + cast (@EditEndTime as varchar(100))


	set @editStartTime = dbo.GetDateTimeFromPeriodID(@periodStart-600)
	set @editEndTime = dbo.GetDateTimeFromPeriodID(@periodEnd)
	
	Set @queryTime = getUTCDate()

	if @newSystemID is null or @newStateID is null
	Begin
		print 'Bad systemid passed: ' + cast (@newSystemID as varchar(10))
		print 'Bad stateid passed: ' + cast (@newStateID as varchar(10))
		return -1 
	end	

	
	print 'Query time ' + cast (@queryTime as varchar(100))
	print 'Calculated EditStartTime ' + cast (@EditStartTime as varchar(100))
	print 'Calculated EditEndTime ' + cast (@EditEndTime as varchar(100))
	print 'Period start:' + cast (@periodStart	 as varchar(100))
	print 'Period end:' + cast (@periodEnd	 as varchar(100))
	
--------------------------------------------------------------
-- Create a temporary table for the edits.
-- Should be a copy of t_EventData - update when t_EventData changes!
--------------------------------------------------------------



-- inserting all - even the ones that don't need editing.
print 'Pulling data into temporary edits table'

Set @timerStart = current_timestamp

-- Create a copy of t_eventData.
CREATE TABLE #tt_Events (
	[SiteID] [int] NOT NULL,
	[ID] [int] NOT NULL,
	[ts_start] [datetime] NOT NULL,
	[EventID] [int] NOT NULL,
	[param1] [float] NULL,
	[param2] [float] NULL,
	[StateID] [int] NULL,
	[SystemID] [int] NULL,
	[ts_end] [datetime] NOT NULL,
	[periodID] [bigint] NOT NULL,
	[EventKey] [bigint] NOT NULL,
	[StateKey] [bigint] NULL,
	[SystemKey] [bigint] NULL,
	[ValidFrom] [datetime] NOT NULL,
	[ValidTo] [datetime] NOT NULL,
	[duration_ms] [int] NOT NULL
)
--------------------------------------------------------------
-- If groupID > 0 (and has been tested above), then pull group members into the edits.
-- If not, then edit based on the siteID.
--------------------------------------------------------------

if (@GroupID > 0) 
	Begin
		insert into #tt_events(SiteID,ID,ts_start,EventID,param1,param2,StateID,
			SystemID,ts_end,periodID,
			EventKey,StateKey,SystemKey,ValidFrom,ValidTo,duration_ms)	
		select 
			t_eventData.SiteID,t_eventData.ID,ts_start,EventID,param1,param2,StateID,
			SystemID,ts_end,periodID,
			EventKey,StateKey,SystemKey,ValidFrom,ValidTo,duration_ms	
		from t_EventData
		inner join t_groupMembers on t_eventData.siteID = t_groupMembers.siteID and t_eventData.id = t_groupMembers.id
				where GroupID = @groupID
				and periodID between @periodStart and @periodEnd
				--and ts_start >= @editStartTime
				--and ts_end <= @editEndTime

	end
else
	begin
		insert into #tt_events(SiteID,ID,ts_start,EventID,param1,param2,StateID,
			SystemID,ts_end,periodID,
			EventKey,StateKey,SystemKey,ValidFrom,ValidTo,duration_ms)	
		select 
			t_eventData.SiteID,t_eventData.ID,ts_start,EventID,param1,param2,StateID,
			SystemID,ts_end,periodID,
			EventKey,StateKey,SystemKey,ValidFrom,ValidTo,duration_ms	
		from t_EventData
				where SiteID = @SiteID
				and periodID between @periodStart and @periodEnd
				--and ts_start >= @editStartTime
				--and ts_end <= @editEndTime

	End


--select * from #tt_events

declare @dataCount bigint

select @dataCount = count(*) from #tt_events


if @dataCount > 30000 
Begin
	drop table #tt_events
	print 'too many records selected: ' + cast (@dataCount as varchar(10)) + ', max 30000'
	select 'too many records selected: ' + cast (@dataCount as varchar(10)) + ', max 30000'
	return -1;	
End


if @dataCount < 1
Begin
	drop table #tt_events
	print 'no data found for edit'
	select 'no data found for edit'
	return -1;	
End


-------------------------------------------------------------------
-- Do the updates
-------------------------------------------------------------------

update #tt_events set stateID = @newStateID, systemID = @newSystemID, validFrom = @QueryTime where ((stateID = 0 and systemID = 0))

--select * from #tt_events order by siteID, id, ts_start
create unique clustered index pk_id_periodID_ts on #tt_events (siteID, id, periodID, ts_start)

-----------------------------------------------------------------------------------------
-- Loop through #tt_events by ID, then update the state / system keys.
-----------------------------------------------------------------------------------------


	DECLARE turb_cursor CURSOR FOR SELECT distinct siteID, id from #tt_events order by siteID, id

	OPEN turb_cursor
	FETCH NEXT FROM turb_cursor INTO @SiteID, @turbID
		

	WHILE @@FETCH_STATUS = 0
	BEGIN
		print 'New turbineID' + cast (@turbID as varchar(100))
				
			
		-------------------------------------------------------------------
		-- possibly overkill: 
		-- update states.
		-------------------------------------------------------------------
		
		set @ts_startKey = @editStartTime -- reset to edit start time.

		while @ts_startKey < @editEndTime
		
			Begin
			
				with StateRecursion (siteID, id, ts_start, ts_end, periodID, stateID, systemID, level)
				as
				(
				-- Anchor member definition
				select siteID, id, ts_start, ts_end, periodID, stateID, systemID, 0 as level
				from #tt_events where siteID = @siteID and id = @turbID and ts_start = @ts_StartKey
				Union all 

				-- Recursive member definition
				select e.siteID, e.id, e.ts_start, e.ts_end, e.periodID, e.stateID, e.systemID, level+1 as level
				from #tt_events  as e inner join stateRecursion as d
				on e.siteID = d.siteID and e.id = d.id and e.periodID between d.periodID and d.periodID + 600 and e.ts_start = d.ts_end and e.stateID = d.stateID

				)
				--select dbo.getLocalTimestampFromDB(siteID, ts_start) as ts_local, siteID, id, ts_start, ts_end, periodID, eventID, stateID, systemID, eventKey, stateKey, systemKey, level
				select @UpdateKeyfrom = min(ts_start), @UpdateKeyTo = max(ts_end)
				from StateRecursion
				group by siteID, id		
				option (maxrecursion 32767)
				
				set @newKey = dbo.getEventKeyFromDateTime(@UpdateKeyFrom)
				
				
				update #tt_events set stateKey = @newKey where siteID = @siteID and id = @turbID and ts_start >= @UpdatekeyFrom and ts_start < @updateKeyTo 
					and ts_end > @UpdateKeyFrom and ts_End <= @UpdateKeyTo
					
				set @ts_startKey = @updateKeyTo
				
			end
		

		-------------------------------------------------------------------
		-- possibly overkill: 
		-- update systems
		-------------------------------------------------------------------
		
		set @ts_startKey = @editStartTime  -- reset to edit start time.
		
		while @ts_startKey < @editEndTime
			
			Begin
			
				with systemRecursion (siteID, id, ts_start, ts_end, periodID, StateID, SystemID, level)
				as
				(
				-- Anchor member definition
				select siteID, id, ts_start, ts_end, periodID, stateID, systemID, 0 as level
				from #tt_events where siteID = @siteID and id = @turbID and ts_start = @ts_StartKey
				Union all 

				-- Recursive member definition
				select e.siteID, e.id, e.ts_start, e.ts_end, e.periodID, e.stateID, e.systemID, level+1 as level
				from #tt_events  as e inner join systemRecursion as d
				on e.siteID = d.siteID and e.id = d.id and e.periodID between d.periodID and d.periodID + 600 and e.ts_start = d.ts_end and e.systemID = d.systemID

				)
				--select dbo.getLocalTimestampFromDB(siteID, ts_start) as ts_local, siteID, id, ts_start, ts_end, periodID, eventID, systemID, systemID, eventKey, systemKey, systemKey, level
				select @UpdateKeyfrom = min(ts_start), @UpdateKeyTo = max(ts_end)
				from systemRecursion
				group by siteID, id		
				option (maxrecursion 32767)
				
				set @newKey = dbo.getEventKeyFromDateTime(@UpdateKeyFrom)
				
				update #tt_events set systemKey = @newKey where siteID = @siteID and id = @turbID and ts_start >= @UpdatekeyFrom and ts_start < @updateKeyTo 
					and ts_end > @UpdateKeyFrom and ts_End <= @UpdateKeyTo
					
				set @ts_startKey = @updateKeyTo
				
			end


		

		-- get the next turbine
	  FETCH NEXT FROM turb_cursor INTO @siteID, @turbID;
	  
	END
	
	
	close turb_cursor
	deallocate turb_cursor


		
	print 'done with the cursor'

-------------------------------------------------------------------------
-- find matching stateID's where the state Key should be continued from previous state key

--	select * from #tt_events order by siteID,id, ts_start
	
	
	
	update #tt_events set stateKey = newStateKey 
	from #tt_events inner join 
	(
	select t_eventData.siteID, t_eventData.id, 
		#tt_events.StateKey as oldStateKey, 
		t_eventData.stateKey as newStateKey 
	 from t_eventData inner join #tt_events 
	 on t_eventData.siteID = #tt_events.siteID and t_eventData.id = #tt_events.id 
		and t_eventData.ts_end = #tt_events.ts_start
		and t_eventData.stateID = #tt_events.stateID
		
	 where t_eventData.periodID = @periodStart - 600
  	and  #tt_events.periodID = @periodStart
	) as a
	on #tt_events.siteID = a.siteID and #tt_events.id = a.id and #tt_events.stateKey = oldStateKey
	
	
-------------------------------------------------------------------------
-- find matching systemID's where the system Key should be continued from previous System key

	update #tt_events set SystemKey = newSystemKey 
	from #tt_events inner join 
	(
	select t_eventData.siteID, t_eventData.id, 
		#tt_events.SystemKey as oldSystemKey, 
		t_eventData.SystemKey as newSystemKey 
	 from t_eventData inner join #tt_events 
	 on t_eventData.siteID = #tt_events.siteID and t_eventData.id = #tt_events.id 
		and t_eventData.ts_end = #tt_events.ts_start
		and t_eventData.SystemID = #tt_events.SystemID
		
	 where t_eventData.periodID = @periodStart - 600
  	and  #tt_events.periodID = @periodStart
	) as a
	on #tt_events.siteID = a.siteID and #tt_events.id = a.id and #tt_events.SystemKey = oldSystemKey
	



--	select * from #tt_events order by siteID,id, ts_start

-------------------------------------------------------------------
-- Start and end times of the first and last keys


set @timerEnd = current_timestamp
set @ms_elapsed = datediff(millisecond, @timerStart, @timerEnd)

print 'time (ms):' + cast (@ms_elapsed as varchar(100))

    BEGIN TRY 
        BEGIN TRANSACTION 


------------------------------------------------------------------------------------------
-- Record the edit.
------------------------------------------------------------------------------------------

    insert into t_edits(siteID, id, ts_EditStart, ts_editEnd, ts_edit, fieldID, UserName, 
			comment, Period_From, Period_To, newVal, newVal2, [Note], groupID)
		values (@siteID, @turbID, @EditStartTime, @EditEndTime, @queryTime, @editFieldID, @strUserName, 
		'Set state = ' + @newState + ', system = ' + @newSystem, 
		@PeriodStart, @periodEnd, @newStateID, @newSystemID, @strNote, @groupID)

------------------------------------------------------------------------------------------
-- Copy the edited data to the t_events_edited table.
------------------------------------------------------------------------------------------

	insert into t_eventData_edited(SiteID,ID,ts_start,EventID,param1,param2,StateID,
			SystemID,ts_end,periodID, EventKey,StateKey,SystemKey,ValidFrom,ValidTo,duration_ms)
	select
		t_EventData.SiteID,t_EventData.ID,t_EventData.ts_start,t_EventData.EventID,t_EventData.param1,
		t_EventData.param2,t_EventData.StateID, t_EventData.SystemID,t_EventData.ts_end,t_EventData.periodID,
		t_EventData.EventKey,t_EventData.StateKey,t_EventData.SystemKey,t_EventData.ValidFrom,
		@queryTime as ValidTo, -- Remember to set this one!
		t_EventData.duration_ms
	from t_EventData
		inner join #tt_events as j
			on t_eventData.SiteID = j.SiteID
			and t_eventData.id = j.ID
			and t_eventData.PeriodID = j.PeriodID
			and t_eventData.ts_start = j.ts_start

------------------------------------------------------------------------------------------
-- Update the t_eventData table
------------------------------------------------------------------------------------------

	update t_EventData set 
		t_EventData.StateID = j.StateID, 
		t_eventData.StateKey = j.StateKey,
		t_EventData.SystemID = j.SystemID, 
		t_eventData.SystemKey = j.SystemKey,
		t_EventData.ValidFrom = j.ValidFrom,
		t_EventData.ValidTo = j.ValidTo
	from t_EventData
		inner join #tt_events as j
			on t_eventData.SiteID = j.SiteID
			and t_eventData.id = j.ID
			and t_eventData.PeriodID = j.PeriodID
			and t_eventData.ts_start = j.ts_start

--------------------------------------------
-- Update new subsequent State keys.
--------------------------------------------

	update t_eventData set stateKey = newStateKey, ValidFrom = @queryTime
	from t_eventData inner join
	(
	select t_eventData.siteID, t_eventData.id, 
		case when #tt_events.stateID = t_eventData.stateID then #tt_events.StateKey else @periodEnd end as NewStateKey,  
			t_eventData.StateKey as oldStateKey 
	 from t_eventData inner join #tt_events 
		on t_eventData.siteID = #tt_events.siteID and t_eventData.id = #tt_events.id 
		and t_eventData.ts_Start = #tt_events.ts_End
		
	 where t_eventData.periodID = @periodEnd + 600
  	 and  #tt_events.periodID = @periodEnd
	) as a
	on t_eventData.siteID = a.siteID and t_eventData.id = a.id and t_eventData.stateKey = oldStateKey
	where t_eventData.periodID > @periodEnd
	
--------------------------------------------
-- Update new subsequent System keys.
-- note setting validFrom = @queryTime
--------------------------------------------
	
	update t_eventData set SystemKey = newSystemKey, ValidFrom = @queryTime
	from t_eventData inner join
	(
		select t_eventData.siteID, t_eventData.id, 
		case when #tt_events.SystemID = t_eventData.SystemID then #tt_events.SystemKey else @periodEnd end as NewSystemKey,  
			t_eventData.SystemKey as oldSystemKey 
	 from t_eventData inner join #tt_events 
		on t_eventData.siteID = #tt_events.siteID and t_eventData.id = #tt_events.id 
		and t_eventData.ts_Start = #tt_events.ts_End
	 where t_eventData.periodID = @periodEnd + 600
  	 and  #tt_events.periodID = @periodEnd
  	 ) as a
	on t_eventData.siteID = a.siteID and t_eventData.id = a.id and t_eventData.SystemKey = oldSystemKey
	where t_eventData.periodID > @periodEnd



--------------------------------------------
-- Do the transaction
--------------------------------------------
        
	--ROLLBACK TRANSACTION
    COMMIT TRANSACTION  -- do the transaction!
	
    END TRY 

    BEGIN CATCH 
      
        ROLLBACK TRANSACTION
		print 'Edit not committed'
		PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR); 
        PRINT 'Error Message: ' + ERROR_MESSAGE(); 
        PRINT 'Error Severity: ' + CAST(ERROR_SEVERITY() AS VARCHAR); 
        PRINT 'Error State: ' + CAST(ERROR_State() AS VARCHAR); 
        PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR); 
        PRINT 'Error Proc: ' + ERROR_PROCEDURE(); 
		select ERROR_NUMBER();
        RETURN ERROR_NUMBER(); 
       
    END CATCH 



--select * from #tt_events order by ts_start
select 'Set state = ' + @newState + ', system = ' + @newSystem
Drop table #tt_events
return 0


END


GO
/****** Object:  StoredProcedure [dbo].[sp_UpdateSystem]    Script Date: 3/26/2019 2:53:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_UpdateSystem]
	@siteID int, @turbine varchar(100), @EditstartTime datetime, @EditendTime datetime, 
	@newSystem varchar(100), @strUserName varchar(100), @strNote varchar(1000) = ''

AS
BEGIN
	SET NOCOUNT ON;

	Declare @queryTime datetime 
	Declare @periodStart bigint, @periodEnd bigInt
	Declare @TurbID int
	Declare @NewSystemID int
	Declare @firstKey bigint, @lastKey bigint
	Declare @firstKey_startTS datetime, @firstKey_endTS dateTime
	Declare @lastKey_startTS datetime, @lastKey_endTS dateTime
	Declare @ts_editStart dateTime, @ts_editEnd datetime
	Declare @subsequentSystemID integer, @subsequentSystemKey bigint
	Declare @PrevSystemID integer, @PrevSystemKey bigint
	Declare @newSystemKey bigint, @newSubsequentSystemKey bigInt
	Declare @timerStart datetime, @timerEnd dateTime, @ms_elapsed int
	Declare @editFieldID integer
	Declare @tz_offset_h integer


	select @editFieldID = FieldID from t_EditFields where lower(FieldName) = lower('System')

	select @tz_offset_h = tz_offsetFromHistorian_h from t_sites where siteID = @siteID
	set @EditstartTime = dateAdd(hour, -1 * @tz_offset_h, @EditstartTime)
	set @EditEndTime = dateAdd(hour, -1 * @tz_offset_h, @EditEndTime)

	Set @queryTime = getUTCDate() -- might just use the editDate
	Set @turbID = null
	Set @newSystemID = null
	
	
	-- need some data validation here. in case these are no good.
	select @turbID = id from t_siteConfig where [turbine] = @turbine and siteID = @siteID
	select @newSystemID = SystemID from t_Systems where [System] = @newSystem

	if @turbID is null 
	Begin
		print 'Bad turbine id passed: ' + @turbine
		return -1
	end


	if @newSystemID is null 
	Begin
		print 'Bad systemid passed: ' + @newSystem
		return -1
	end

	print 'Edited turbID: ' + cast (@turbID as varchar(10)) + ' passed: ' + @turbine

	set @periodStart = dbo.GetPeriodIDFromDateTime (@EditstartTime) -- remember that the editStartTime is the tail end of the period.
	set @periodEnd = dbo.GetPeriodIDFromDateTime(@EditendTime)

	print 'Query time ' + cast (@queryTime as varchar(100))
	print 'Requested EditStartTime ' + cast (@EditStartTime as varchar(100))
	print 'Requested EditEndTime ' + cast (@EditEndTime as varchar(100))
	print 'Period start:' + cast (@periodStart	 as varchar(100))
	print 'Period end:' + cast (@periodEnd	 as varchar(100))
	
--------------------------------------------------------------
-- Create a temporary table for the inserts.
-- Should be a copy of t_EventData - update when t_EventData changes!
--------------------------------------------------------------

declare @tt_events TABLE ([SiteID] [int],	[ID] [int],	[ts_start] [datetime],
	[EventID] [int],	[param1] [float],	[param2] [float],	[StateID] [int],
	[SystemID] [int],	[ts_end] [datetime],	[periodID] [bigint],	[EventKey] [bigint],
	[StateKey] [bigint],	[SystemKey] [bigint],	[ValidFrom] [datetime],
	[ValidTo] [datetime],	[duration_ms] [int], [R] [int])


print 'initial insert into edit table, including 1 overhanging record.: '

Set @timerStart = current_timestamp

insert into @tt_events(SiteID,ID,ts_start,EventID,param1,param2,StateID,
	SystemID,ts_end,periodID,
	EventKey,StateKey,SystemKey,ValidFrom,ValidTo,duration_ms)
select
	SiteID,ID,ts_start,EventID,param1,param2,StateID,
	SystemID,ts_end,periodID,
	EventKey,StateKey,SystemKey,ValidFrom,ValidTo,duration_ms
from t_EventData
		where siteID = @siteID
		and id = @turbID
		and periodID between @periodStart-600 and @periodEnd+600
	--	and validFrom <= @queryTime and ValidTo > @queryTime

set @timerEnd = current_timestamp
set @ms_elapsed = datediff(millisecond, @timerStart, @timerEnd)
print 'time (ms):' + cast (@ms_elapsed as varchar(100))

--- find first and last keys - determine if I need to edit these.
	select top 1 @firstKey = SystemKey 
		from @tt_events where periodID = @periodStart order by ts_start

	select top 1 @lastKey = SystemKey
		from @tt_events where periodID = @periodEnd	order by ts_start desc

	print 'First Key: ' + cast (@firstKey as varchar(100))
	print 'Last Key: ' + cast (@lastKey as varchar(100))

-----------------------------------------------------------------------------------
-- Update the rank in the @tt_events table
-- Actually, the whole table doesn't need to be edited - could change.
-----------------------------------------------------------------------------------

print 'Setting rank:'
Set @timerStart = current_timestamp

	update @tt_events set t.R = DisplayRank
	from @tt_events as t inner join 
	(	
		select siteID, id, periodID, ts_start, Rank() 
			over (partition by siteid, id, periodID 
			order by case when SystemID = 0 then 1 else 0 end, 
			duration_ms desc, ts_start) as DisplayRank
		from @tt_events as b
		where (periodID between @periodStart-600 and @periodStart
			or periodID between @periodEnd and @periodEnd+600)

	)  as a
	on t.siteID = a.siteID and t.id = a.id and t.PeriodID = a.PeriodID and t.ts_start = a.ts_start

set @timerEnd = current_timestamp
set @ms_elapsed = datediff(millisecond, @timerStart, @timerEnd)
print 'time (ms):' + cast (@ms_elapsed as varchar(100))


-------------------------------------------------------------------
-- Start and end times of the first and last keys

	select @firstKey_startTS = min(ts_start), @firstKey_endTS = max(ts_end) 
		from @tt_events
		where SystemKey = @firstKey		

	select @lastKey_startTS = min(ts_start), @lastKey_endTS = max(ts_end)
		from @tt_events 
		where SystemKey = @lastKey		

-------------------------------------------------------------------
-- Rank of the first and last keys in the first and last periods of the edit, plus the prev and subsequent ones.

	Declare @FirstKeyRankPrev integer, @firstKeyRankFirst  integer
	Declare @lastKeyRankLast integer, @lastKeyRankSubsequent integer

	Set @FirstKeyRankPrev = NULL -- This should make 
	Set @FirstKeyRankFirst = null
	Set @lastKeyRankLast = null
	Set @lastKeyRankSubsequent = null


	select @FirstKeyRankPrev = R from @tt_events where periodID = @periodStart-600 and SystemKey = @firstKey		
	select @FirstKeyRankFirst = R from @tt_events where periodID = @periodStart and SystemKey = @firstKey		
	select @LastKeyRankLast = R from @tt_events where periodID = @periodEnd and SystemKey = @LastKey		
	select @LastKeyRankSubsequent = R from @tt_events where periodID = @periodEnd + 600 and SystemKey = @LastKey		
	
	set @firstKeyRankPrev = isNull(@firstKeyRankPrev, 100)
	set @firstKeyRankFirst = isNull(@firstKeyRankFirst, 100)
	set @LastKeyRankLast = isNull(@LastKeyRankLast, 100)
	set @LastKeyRankSubsequent = isNull(@LastKeyRankSubsequent, 100)

	print 'FirstKey ' + cast (@firstKey as varchar(10))

	print 'FirstKeyRankPrev ' + cast (@firstKeyRankPrev as varchar(10))
	print 'FirstKeyRankFirst ' + cast (@firstKeyRankFirst as varchar(10))
	print 'FirstKeyRankLast ' + cast (@LastKeyRankLast as varchar(10))
	print 'FirstKeyRankSubsequent ' + cast (@LastKeyRankSubsequent as varchar(10))

-- Decide whether or not to edit the event labelled with firstKey.--------------------------------

	set @ts_editStart = dbo.GetDateTimeFromPeriodID (@periodStart-600) 
	print 'ts_editStart: ' + cast(@ts_editSTart as varchar(100))

	if @firstKey_EndTS < @editStartTime -- FirstKey event ends in first period:
		Begin
			print 'First key ends in first period'
		
			if (@firstKeyRankFirst <> 1 and @firstKeyRankPrev = 1)	-- You don't see it in the first period but see it in the prev - don't edit.
			begin
				
				set @ts_editStart = @firstKey_EndTS		
			end
		End
	else -- FirstKey extends beyond the first period.  Check whether to edit any of the previous periods.
		begin
			if (dateDiff(second, @firstKey_startTS, dbo.GetDateTimeFromPeriodID(@periodStart)) < 1200 
				and @firstKeyRankPrev <> 1 ) -- the System starts in the previous Period and you wouldn't see it in the prev period:
				begin
					set @ts_editStart = @firstKey_startTS
				end
		end 

	print 'ts_editStart (new!): ' + cast(@ts_editSTart as varchar(100))

-- Decide whether or not to edit the event labelled with lastKey.--------------------------------

	set @ts_editEnd = dbo.GetDateTimeFromPeriodID (@periodEnd)
	print 'ts_editEnd: ' + cast(@ts_editEnd as varchar(100))

	if @LastKey_StartTS > dbo.GetDateTimeFromPeriodID(@periodEnd-600) -- LastKey starts during the last period.  Check whether to include.
	Begin
		if (@LastKeyRankLast <> 1 and @lastKeyRankSubsequent = 1)
		begin	
			set @ts_editEnd = @lastKey_StartTS
		end
	end
	else -- LastKey starts prior to the last period.  Decide whether to extend to the subsequent periods.
	begin 
		if (dateDiff(second, dbo.GetDateTimeFromPeriodID(@periodEnd), @LastKey_EndTS) < 600
			and @lastKeyRankSubsequent <> 1) 
			begin
				set @ts_editEnd = @lastKey_EndTS
			End
	end

	print 'ts_editEnd (new): ' + cast(@ts_editEnd as varchar(100))


-----------------------------------------------------------------------------------------
-- Chop the temporary event table at ts_editStart and ts_editEnd.
	print 'Deleting beyond editStart and editEnd'
	delete from @tt_events where ts_start < @ts_editStart or ts_start >= @ts_editEnd

-----------------------------------------------------------------------------------------
-- Update the temporary event table.

	print 'Updating the temp table with the new events!'
	update @tt_events set SystemID = @newSystemID 
		where ts_start >= @ts_editStart and ts_start < @ts_editEnd

-------------------------------------------------------------------------------------------------------------------
-- Update the Valid Dates!!!
-------------------------------------------------------------------------------------------------------------------

 Update @tt_events set ValidFrom = @queryTime, ValidTo = '2100-01-01'

-----------------------------------------------------------------------------------------
-- Update the SystemKey for the edited records.
-----------------------------------------------------------------------------------------

	set @prevSystemID = null
	set @prevSystemKey = null

	select @prevSystemID = SystemID, @prevSystemKey = SystemKey
		from t_eventData 
		where siteID = @siteID
		and id = @turbID
		and periodID between @periodStart-600 and @periodStart -- in the prev or first records.
		--and validFrom <= @queryTime and ValidTo > @queryTime
		and ts_end = @ts_editStart

	print 'Previous System and key: ' + cast (@prevSystemID as varchar(100)) + ' , ' +  cast(@prevSystemKey as varchar(100))

	if @prevSystemID = @NewSystemId -- editing to make it the same ... will have to set the System key to be PrevSystemKey.
		Begin
			set @newSystemKey = @prevSystemKey 
		end
	else -- editing to make it different.  I think that this would handle a null prevSystemKey.
		Begin
			set @newSystemKey = dbo.GetEventKeyFromDateTime(@ts_EditStart)			
		end

	Update @tt_events set SystemKey = @newSystemKey

	
-----------------------------------------------------------------------------------------
-- Check for change of key at end ...
-- Note: @subsequentSystemKey and @newSubsequentSystemKey are used for the edits within the transaction!!
-----------------------------------------------------------------------------------------

	set @subsequentSystemID = null
	set @subsequentSystemKey = null
	set @NewsubsequentSystemKey = -1 -- This will be used to test whether to update the System keys after the edit.

	select @SubsequentSystemID = SystemID,  @SubsequentSystemKey = SystemKey
		from t_eventData 
		where siteID = @siteID
		and id = @turbID
		and periodID between @periodEnd and @periodEnd + 600 -- in the prev or first records.
		and validFrom <= @queryTime and ValidTo > @queryTime
		and ts_start = @ts_editEnd

	if (@subsequentSystemKey is not null)  -- means there is some following data.
	Begin
		if @subsequentSystemID = @newSystemID 
			set @newSubsequentSystemKey = @newSystemKey -- same	
		else if @subsequentSystemKey <> dbo.GetEventKeyFromDateTime (@ts_editEnd) 
			set @newSubsequentSystemKey = dbo.GetEventKeyFromDateTime (@ts_editEnd)
	End
	else 
		print 'subsequent System ID is null, not examining subsequent System keys!'


		print 'subsequent System key: ' + cast (@SubsequentSystemKey as varchar(10))
		print 'new System key: ' + cast (@newSubsequentSystemKey as varchar(10))


	Declare @ts_forReporting datetime

	if @newSubsequentSystemKey > 0
	begin
		select @ts_forReporting =  min(ts_start) from t_eventData where SystemKey = @subsequentSystemKey and ts_start >= @ts_editEnd
			and siteID = @siteID  and id = @turbID and periodID >= @periodEnd
		print 'updating records from ' + cast (@ts_forReporting as varchar(100))
		select @ts_forReporting = max(ts_end) from t_eventData where SystemKey = @subsequentSystemKey  and ts_start >= @ts_editEnd
			and siteID = @siteID  and id = @turbID and periodID >= @periodEnd
		print 'updating records to ' + cast (@ts_forReporting as varchar(100))
		print 'with new System key: ' + + cast (@newSubsequentSystemKey as varchar(10))
	end



/*	-- If the period after the edit isn't the same as the new edited value, give it a new start TS.
	update @tt_events set SystemKey = dbo.GetEventKeyFromDateTime(@ts_EditEnd)
		where ts_start >= @ts_editEnd and SystemID <> @newSystemID
*/

    BEGIN TRY 
        BEGIN TRANSACTION 


------------------------------------------------------------------------------------------
-- Record the edit.
------------------------------------------------------------------------------------------

    insert into t_edits(siteID, id, ts_editStart, ts_editEnd, ts_edit, fieldID, UserName, 
			comment, Period_From, Period_To, newVal)
		values (@siteID, @turbID, @ts_editStart, @ts_editEnd, @queryTime, @editFieldID, @strUserName, 
		'Set System = ' + @NewSystem + ' for Turbine ' + @turbine, @PeriodStart, @periodEnd, @newSystemID)

------------------------------------------------------------------------------------------
-- Copy the edited data to the t_events_edited table.
------------------------------------------------------------------------------------------

	insert into t_eventData_edited(SiteID,ID,ts_start,EventID,param1,param2,StateID,
			SystemID,ts_end,periodID, EventKey,StateKey,SystemKey,ValidFrom,ValidTo,duration_ms)
	select
		t_EventData.SiteID,t_EventData.ID,t_EventData.ts_start,t_EventData.EventID,t_EventData.param1,
		t_EventData.param2,t_EventData.StateID, t_EventData.SystemID,t_EventData.ts_end,t_EventData.periodID,
		t_EventData.EventKey,t_EventData.StateKey,t_EventData.SystemKey,t_EventData.ValidFrom,
		@queryTime as ValidTo, -- Remember to set this one!
		t_EventData.duration_ms
	from t_EventData
		inner join @tt_events as j
			on t_eventData.SiteID = j.SiteID
			and t_eventData.id = j.ID
			and t_eventData.PeriodID = j.PeriodID
			and t_eventData.ts_start = j.ts_start
	--where t_eventData.validFrom <= @queryTime and t_eventData.ValidTo > @queryTime -- This "where" not necessary anymore.

------------------------------------------------------------------------------------------
-- Update the t_eventData table
------------------------------------------------------------------------------------------

	update t_EventData set t_EventData.SystemID = j.SystemID, 
		t_eventData.SystemKey = j.SystemKey,
		t_EventData.ValidFrom = j.ValidFrom,
		t_EventData.ValidTo = j.ValidTo
	from t_EventData
		inner join @tt_events as j
			on t_eventData.SiteID = j.SiteID
			and t_eventData.id = j.ID
			and t_eventData.PeriodID = j.PeriodID
			and t_eventData.ts_start = j.ts_start
	--where t_eventData.validFrom <= @queryTime and t_eventData.ValidTo > @queryTime -- This "where" not necessary anymore.


--------------------------------------------
-- Update new subsequent System keys.
--------------------------------------------

	if @newSubsequentSystemKey > 0 
	Begin
		update t_eventData set SystemKey = @newSubsequentSystemKey where SystemKey = @subsequentSystemKey and ts_start >= @ts_editEnd
			and siteID = @siteID and id = @TurbID
	end

--------------------------------------------
-- Do the transaction
--------------------------------------------
        
	--ROLLBACK TRANSACTION
      COMMIT TRANSACTION  -- do the transaction!
	
    END TRY 

    BEGIN CATCH 
      
        ROLLBACK TRANSACTION
		print 'Edit not committed'
		PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR); 
        PRINT 'Error Message: ' + ERROR_MESSAGE(); 
        PRINT 'Error Severity: ' + CAST(ERROR_SEVERITY() AS VARCHAR); 
        PRINT 'Error State: ' + CAST(ERROR_State() AS VARCHAR); 
        PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR); 
        PRINT 'Error Proc: ' + ERROR_PROCEDURE(); 
		select ERROR_NUMBER();
        RETURN ERROR_NUMBER(); 
       
    END CATCH 

--select * from @tt_events order by ts_start
select 'Set System = ' + @NewSystem + ' for Turbine ' + @turbine

return 0


END

/*
insert into t_eventCodes (eventID, description, defaultSystemID, defaultSystemID,turbTypeID)
values (223, 'Stop', 2, 672, 1)

insert into t_eventCodes (eventID, description, defaultSystemID, defaultSystemID,turbTypeID)
values (430, 'Transmission Oscillation __ RPM, __ m/s', 2, 668, 1)

*/

GO
