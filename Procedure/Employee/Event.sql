USE WALTRONICS;
GO

DROP PROCEDURE Employee.GetEvents;
GO

CREATE PROCEDURE Employee.GetEvents (
	@SessionID CHAR(36)
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

	SELECT	0 AS EventID,
			CAST(@SessionEmployeeID AS UNIQUEIDENTIFIER) AS EmployeeID,
			'Date' = 
			CASE
				WHEN InfoStatus.Status = 'Done' THEN Appointment.Date.EndDate
				ELSE Appointment.Date.StartDate
			END,
			'Summary' =
			CASE
				WHEN InfoStatus.Status = 'Scheduled'	THEN 'Appointment is scheduled for drop-off today.'
				WHEN InfoStatus.Status = 'Evaluation'	THEN 'Appointment is scheduled to be evaluated today.'
				WHEN InfoStatus.Status = 'Done'			THEN 'Appointment is scheduled for pick-up today. Make sure that you''ve received payment before sending off the vehicle.'
			END,
			'Name' = 
			CASE
				WHEN InfoStatus.Status = 'Scheduled'	THEN Customer.FName + ' ' + Customer.LName + ' Scheduled'
				WHEN InfoStatus.Status = 'Evaluation'	THEN Customer.FName + ' ' + Customer.LName + ' Evaluation'
				WHEN InfoStatus.Status = 'Done'			THEN Customer.FName + ' ' + Customer.LName + ' Ready for Pick-Up'
			END,
			CAST(Appointment.ID.AppointmentID AS UNIQUEIDENTIFIER) AS AppointmentID
	FROM	Appointment.Date
	JOIN	Appointment.ID ON Appointment.Date.AppointmentID = Appointment.ID.AppointmentID
	JOIN	Customer.Customer ON Customer.Customer.CustomerID = Appointment.ID.CustomerID
	JOIN	Appointment.Status AS AppointmentStatus ON Appointment.Date.AppointmentID = AppointmentStatus.AppointmentID
	JOIN	Info.Status AS InfoStatus ON AppointmentStatus.StatusID = InfoStatus.StatusID
	WHERE	(StartDate IS NOT NULL OR EndDate IS NOT NULL) AND
			InfoStatus.Status IN ('Scheduled', 'Evaluation', 'Done')
	UNION
	SELECT	Employee.Event.EventID,
			Employee.Event.EmployeeID,
			Employee.Event.Date,
			Employee.Event.Name,
			Employee.Event.Summary,
			CAST(NULL AS UNIQUEIDENTIFIER) AS AppointmentID
	FROM	Employee.Event
	WHERE	Employee.Event.EmployeeID = @SessionEmployeeID
	UNION
	SELECT	Employee.Event.EventID,
			Employee.Event.EmployeeID,
			Employee.Event.Date,
			Employee.Event.Name,
			Employee.Event.Summary,
			CAST(NULL AS UNIQUEIDENTIFIER) AS AppointmentID
	FROM	Employee.Event
	JOIN	Employee.SharedEvent ON Employee.Event.EventID = Employee.SharedEvent.EventID
	WHERE	Employee.SharedEvent.EmployeeID = @SessionEmployeeID;

	COMMIT TRANSACTION;
END;
GO

DROP PROCEDURE Employee.InsertEvent;
GO

CREATE PROCEDURE Employee.InsertEvent (
	@SessionID	CHAR(36),
	@Name		VARCHAR(100),
	@Date		VARCHAR(100),
	@Summary	VARCHAR(500)
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

	DECLARE @_Date DATETIME2 = CONVERT(DATETIME2, @Date);

	INSERT INTO Employee.Event (EmployeeID, Name, Date, Summary)
	VALUES (
		@SessionEmployeeID,
		@Name,
		@_Date,
		@Summary
	);

	SELECT SCOPE_IDENTITY() AS EventID;

	COMMIT TRANSACTION;
END;
GO

DROP PROCEDURE Employee.DeleteEvent;
GO

CREATE PROCEDURE Employee.DeleteEvent (
	@SessionID	CHAR(36),
	@EventID	INT
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

	DECLARE @EventOwnerID UNIQUEIDENTIFIER = (
		SELECT	EmployeeID
		FROM	Employee.Event
		WHERE	EventID = @EventID
	);

	IF (@EventOwnerID <> @SessionEmployeeID)
	BEGIN
		;THROW 50000, 'UNAUTHORIZED USER', 1;
	END;

	DELETE FROM	Employee.Event
	WHERE		EventID = @EventID AND
				EmployeeID = @EventOwnerID;

	COMMIT TRANSACTION;
END;
GO

DROP PROCEDURE Employee.UpdateEvent;
GO

CREATE PROCEDURE Employee.UpdateEvent (
	@SessionID		CHAR(36),
	@EventID		INT,
	@Name			VARCHAR(100)	= NULL,
	@Date			VARCHAR(30) = NULL,
	@Summary		VARCHAR(500)	= NULL
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

	DECLARE @EventOwnerID UNIQUEIDENTIFIER = (
		SELECT	EmployeeID
		FROM	Employee.Event
		WHERE	EventID = @EventID
	);

	IF (@EventOwnerID <> @SessionEmployeeID)
	BEGIN
		;THROW 50000, 'UNAUTHORIZED USER', 1;
	END;

	IF (@Name IS NOT NULL)
	BEGIN
		UPDATE	Employee.Event
		SET		Name = @Name
		WHERE	EventID = @EventID AND
				EmployeeID = @EventOwnerID;
	END;

	IF (@Date IS NOT NULL)
	BEGIN
		DECLARE @_Date DATETIME2 = CONVERT(DATETIME2, @Date);

		UPDATE	Employee.Event
		SET		Date = @_Date
		WHERE	EventID = @EventID AND
				EmployeeID = @EventOwnerID;
	END;

	IF (@Summary IS NOT NULL)
	BEGIN
		UPDATE	Employee.Event
		SET		Summary = @Summary
		WHERE	EventID = @EventID AND
				EmployeeID = @EventOwnerID;
	END;

	COMMIT TRANSACTION;
END;
GO