USE [WOPR]
GO
/****** Object:  StoredProcedure [dbo].[sp_UpdateStateEdits]    Script Date: 4/01/2019 12:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_UpdateStateEdits]
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

	set @periodStart = dbo.GetPeriodIDFromDateTime (@EditstartTime) -- remember that the editStartTime is the tail end of the period.
	set @periodEnd = dbo.GetPeriodIDFromDateTime(@EditendTime)
	set @ts_editStart = dbo.GetDateTimeFromPeriodID (@periodStart-600)

	set @ts_editEnd = dbo.GetDateTimeFromPeriodID (@periodEnd)
	print 'ts_editEnd: ' + cast(@ts_editEnd as varchar(100))

	Set @queryTime = getUTCDate() 
	Set @turbTypeID = null
	Set @turbID = null
	Set @newStateID = null

	select @turbID = id, @turbTypeID = turbTypeID from t_siteConfig where [turbine] = @turbine and siteID = @siteID
	select @newstateID = stateID from t_states where [state] = @newState

	print 'Edited turbID: ' + cast (@turbID as varchar(10)) + ' passed: ' + @turbine

	print 'Query time ' + cast (@queryTime as varchar(100))
	print 'Requested EditStartTime ' + cast (@EditStartTime as varchar(100))
	print 'Requested EditEndTime ' + cast (@EditEndTime as varchar(100))
	print 'Period start:' + cast (@periodStart	 as varchar(100))
	print 'Period end:' + cast (@periodEnd	 as varchar(100))

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

	BEGIN TRY 
        BEGIN TRANSACTION

	------------------------------------------------------------------------------------------
	-- Update the eventData table.
	------------------------------------------------------------------------------------------

	update t_EventData set t_EventData.stateID = @newstateID, t_eventData.StateKey = @newStateKey
	from t_EventData
		where siteID = @siteID
		and id = @turbID
		and periodID between @periodStart and @periodEnd

	--------------------------------------------
	-- Update new subsequent state keys.
	--------------------------------------------

	if @newSubsequentStateKey > 0 
	Begin
		update t_eventData set stateKey = @newSubsequentStateKey where stateKey = @subsequentStateKey and ts_start >= @ts_editEnd
			and siteID = @siteID and id = @TurbID
	end

	------------------------------------------------------------------------------------------
	-- Record the edit.
	------------------------------------------------------------------------------------------

    insert into t_edits(siteID, id, ts_editStart, ts_editEnd, ts_edit, fieldID, UserName, 
			comment, Period_From, Period_To, newVal)
		values (@siteID, @turbID, @ts_editStart, @ts_editEnd, @queryTime, @editFieldID, @strUserName, 
		'Set State = ' + @newState + ' for Turbine ' + @turbine, @periodStart, @periodEnd, @newstateID)

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