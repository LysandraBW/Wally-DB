DROP PROCEDURE Appointment.UpdateDate;
GO

CREATE PROCEDURE Appointment.UpdateDate (
	@SessionID		CHAR(36),
	@AppointmentID	UNIQUEIDENTIFIER,
	@StartDate		VARCHAR(30) = NULL,
	@EndDate		VARCHAR(30) = NULL
) 
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	BEGIN TRANSACTION;

	DECLARE @SessionEmployeeID UNIQUEIDENTIFIER;
	EXEC	Employee.AuthenticateSession 
			@SessionID, 
			@SessionEmployeeID OUTPUT;

	IF (@StartDate IS NOT NULL)
	BEGIN
		DECLARE @_StartDate DATETIME = CONVERT(DATETIME, @StartDate);

		UPDATE	Appointment.Date
		SET		StartDate = @_StartDate
		WHERE	AppointmentID = @AppointmentID;

		DECLARE @M1 VARCHAR(400) = 'Updated Start Date to ''' + @StartDate + '''';
		EXEC	Employee.LogModification 
				@SessionID, 
				@AppointmentID, 
				@M1;
	END;

	IF (@EndDate IS NOT NULL)
	BEGIN
		DECLARE @_EndDate DATETIME = CONVERT(DATETIME, @EndDate);

		UPDATE	Appointment.Date
		SET		EndDate = @_EndDate
		WHERE	AppointmentID = @AppointmentID;

		DECLARE @M2 VARCHAR(400) = 'Updated End Date to ''' + @EndDate + '''';
		EXEC	Employee.LogModification 
				@SessionID, 
				@AppointmentID, 
				@M2;
	END;

	COMMIT TRANSACTION;
END;
GO