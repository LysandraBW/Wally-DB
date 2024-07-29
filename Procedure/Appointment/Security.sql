USE WALTRONICS;
GO

DROP PROCEDURE Appointment.AuthenticateLookup;
GO

CREATE PROCEDURE Appointment.AuthenticateLookup (
	@AppointmentID	UNIQUEIDENTIFIER,
	@Email			VARCHAR(320),
	@SessionID		CHAR(36) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	BEGIN TRANSACTION;

	DECLARE @_AppointmentID UNIQUEIDENTIFIER;
	SELECT	@_AppointmentID = AppointmentID
	FROM	Appointment.ID		AS A
	JOIN	Customer.Customer	AS C
	ON		A.CustomerID		= C.CustomerID
	WHERE	C.Email				= @Email AND
			A.AppointmentID		= @AppointmentID;
			
	IF (@_AppointmentID IS NULL)
	BEGIN
		;THROW 50000, 'APPOINTMENT NOT FOUND', 1;
	END;
	
	DECLARE @_SessionID CHAR(36);
	EXEC Info.SessionID @_SessionID OUTPUT;

	IF (EXISTS(
			SELECT	1 
			FROM	Appointment.Session 
			WHERE	AppointmentID = @AppointmentID
	))
	BEGIN
		UPDATE	Appointment.Session
		SET		SessionID = @_SessionID,
				LoginDate = GETDATE()
		WHERE	AppointmentID = @AppointmentID;
	END;
	ELSE
	BEGIN
		INSERT INTO Appointment.Session
		VALUES (
			@AppointmentID,
			@_SessionID,
			GETDATE()
		);
	END;

	SELECT @SessionID = @_SessionID;
	COMMIT TRANSACTION;
END;
GO

DROP PROCEDURE Appointment.AuthenticateSession;
GO

CREATE PROCEDURE Appointment.AuthenticateSession (
	@SessionID		CHAR(36),
	@AppointmentID	UNIQUEIDENTIFIER OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	BEGIN TRANSACTION;

	DECLARE @_AppointmentID UNIQUEIDENTIFIER = (
		SELECT	AppointmentID
		FROM	Appointment.Session
		WHERE	SessionID = @SessionID
	);

	IF (@_AppointmentID IS NULL)
	BEGIN
		;THROW 50000, 'UNAUTHENTICATED SESSION', 1;
	END;

	SELECT @AppointmentID = @_AppointmentID;
	COMMIT TRANSACTION;
END;
GO

DROP PROCEDURE Appointment.AuthorizeSession;
GO

CREATE PROCEDURE Appointment.AuthorizeSession (
	@SessionID		CHAR(36),
	@AppointmentID	UNIQUEIDENTIFIER
)
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	BEGIN TRANSACTION;
	
	DECLARE @SessionAppointmentID UNIQUEIDENTIFIER;
	EXEC	Appointment.AuthenticateSession 
			@SessionID, 
			@SessionAppointmentID OUTPUT;

	IF (@SessionAppointmentID <> @AppointmentID)
	BEGIN
		;THROW 50000, 'UNAUTHORIZED APPOINTMENT', 1;
	END;

	COMMIT TRANSACTION;
END;
GO