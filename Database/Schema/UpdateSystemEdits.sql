USE [WOPR]
GO
/****** Object:  StoredProcedure [dbo].[sp_UpdateSystemEdits]    Script Date: 4/01/2019 12:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_UpdateSystemEdits]
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

	set @periodStart = dbo.GetPeriodIDFromDateTime (@EditstartTime) -- remember that the editStartTime is the tail end of the period.
	set @periodEnd = dbo.GetPeriodIDFromDateTime(@EditendTime)

	set @ts_editStart = dbo.GetDateTimeFromPeriodID (@periodStart-600) 
	print 'ts_editStart: ' + cast(@ts_editSTart as varchar(100))

	set @ts_editEnd = dbo.GetDateTimeFromPeriodID (@periodEnd)
	print 'ts_editEnd: ' + cast(@ts_editEnd as varchar(100))

	Set @queryTime = getUTCDate() 
	Set @turbID = null
	Set @newSystemID = null

	-- need some data validation here. in case these are no good.
	select @turbID = id from t_siteConfig where [turbine] = @turbine and siteID = @siteID
	select @newSystemID = SystemID from t_Systems where [Description] = @newSystem

	print 'Edited turbID: ' + cast (@turbID as varchar(10)) + ' passed: ' + @turbine

	set @periodStart = dbo.GetPeriodIDFromDateTime (@EditstartTime) -- remember that the editStartTime is the tail end of the period.
	set @periodEnd = dbo.GetPeriodIDFromDateTime(@EditendTime)

	print 'Query time ' + cast (@queryTime as varchar(100))
	print 'Requested EditStartTime ' + cast (@EditStartTime as varchar(100))
	print 'Requested EditEndTime ' + cast (@EditEndTime as varchar(100))
	print 'Period start:' + cast (@periodStart	 as varchar(100))
	print 'Period end:' + cast (@periodEnd	 as varchar(100))

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

	BEGIN TRY 
        BEGIN TRANSACTION

	------------------------------------------------------------------------------------------
	-- Update the t_eventData table
	------------------------------------------------------------------------------------------

	update t_EventData set t_EventData.SystemID = @newSystemID, 
		t_eventData.SystemKey = @newSystemKey
	from t_EventData
		where siteID = @siteID
		and id = @turbID
		and periodID between @periodStart and @periodEnd

	--------------------------------------------
	-- Update new subsequent System keys.
	--------------------------------------------

	if @newSubsequentSystemKey > 0 
	Begin
		update t_eventData set SystemKey = @newSubsequentSystemKey where SystemKey = @subsequentSystemKey and ts_start >= @ts_editEnd
			and siteID = @siteID and id = @TurbID
	end

	------------------------------------------------------------------------------------------
	-- Record the edit.
	------------------------------------------------------------------------------------------

    insert into t_edits(siteID, id, ts_editStart, ts_editEnd, ts_edit, fieldID, UserName, 
			comment, Period_From, Period_To, newVal)
		values (@siteID, @turbID, @ts_editStart, @ts_editEnd, @queryTime, @editFieldID, @strUserName, 
		'Set System = ' + @newSystem + ' for Turbine ' + @turbine, @periodStart, @periodEnd, @newSystemID)

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
	select 'Set System = ' + @newSystem + ' for Turbine ' + @turbine


return 0

END