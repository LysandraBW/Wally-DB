USE WALTRONICS;
GO

DROP PROCEDURE Appointment.Remove;
GO

CREATE PROCEDURE Appointment.Remove (
	@SessionID		CHAR(36),
	@AppointmentID	UNIQUEIDENTIFIER
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

	IF (@AppointmentID IN (SELECT AppointmentID FROM Appointment.Deleted))
	BEGIN
		EXEC	Employee.LogModification 
				@SessionID, 
				@AppointmentID, 
				'Permanently Deleted Appointment';

		DELETE FROM	Appointment.ID
		WHERE		AppointmentID = @AppointmentID;
	END;
	ELSE
	BEGIN
		INSERT INTO Appointment.Deleted 
		VALUES (@AppointmentID);

		EXEC	Employee.LogModification 
				@SessionID, 
				@AppointmentID, 
				'Temporarily Deleted Appointment';
	END;

	COMMIT TRANSACTION;
END;
GO

DROP PROCEDURE Appointment.PutBack;
GO

CREATE PROCEDURE Appointment.PutBack (
	@SessionID		CHAR(36),
	@AppointmentID	UNIQUEIDENTIFIER
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

	DELETE FROM Appointment.Deleted
	WHERE		AppointmentID = @AppointmentID;

	EXEC	Employee.LogModification 
			@SessionEmployeeID, 
			@AppointmentID, 
			'Restored Appointment';

	COMMIT TRANSACTION;
END;
GO
