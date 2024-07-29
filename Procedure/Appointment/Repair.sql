USE WALTRONICS;
GO

DROP PROCEDURE Appointment.InsertRepair;
GO

CREATE PROCEDURE Appointment.InsertRepair (
	@SessionID		CHAR(36),
	@AppointmentID	UNIQUEIDENTIFIER,
	@Repair			VARCHAR(500)
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

	INSERT INTO Appointment.Repair
	VALUES (
		@AppointmentID,
		@Repair
	);

	DECLARE @S1 VARCHAR(300) =	CASE WHEN LEN(@Repair) > 300 THEN SUBSTRING(@Repair, 1, 300) + '...'
								ELSE @Repair END;

	DECLARE @M1 VARCHAR(400) = CONCAT('Inserted Repair ''', @S1,'''');
	EXEC	Employee.LogModification 
			@SessionID, 
			@AppointmentID, 
			@M1;

	SELECT SCOPE_IDENTITY() AS RepairID;

	COMMIT TRANSACTION;
END;
GO

DROP PROCEDURE Appointment.DeleteRepair;
GO

CREATE PROCEDURE Appointment.DeleteRepair (
	@SessionID		CHAR(36),
	@AppointmentID	UNIQUEIDENTIFIER,
	@RepairID		INT			
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

	DECLARE @Repair VARCHAR(500) = (
		SELECT	Repair 
		FROM	Appointment.Repair 
		WHERE	AppointmentID = @AppointmentID AND 
				RepairID = @RepairID
	);

	DELETE FROM Appointment.Repair
	WHERE		AppointmentID = @AppointmentID AND
				RepairID = @RepairID;

	DECLARE @S1 VARCHAR(300) =	CASE WHEN LEN(@Repair) > 300 THEN SUBSTRING(@Repair, 1, 300) + '...' 
								ELSE @Repair END;

	DECLARE @M1 VARCHAR(400) = 'Deleted Repair ''' + @S1 + '''';
	EXEC	Employee.LogModification 
			@SessionID, 
			@AppointmentID, 
			@M1;

	COMMIT TRANSACTION;
END;
GO

DROP PROCEDURE Appointment.UpdateRepair;
GO

CREATE PROCEDURE Appointment.UpdateRepair (
	@SessionID		CHAR(36),
	@AppointmentID	UNIQUEIDENTIFIER,
	@RepairID		INT,
	@Repair			VARCHAR(500)
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

	UPDATE	Appointment.Repair
	SET		Repair = @Repair
	WHERE	AppointmentID = @AppointmentID AND
			RepairID = @RepairID;

	DECLARE @S1 VARCHAR(300) =	CASE WHEN LEN(@Repair) > 300 THEN SUBSTRING(@Repair, 1, 300) + '...'
								ELSE @Repair END;

	DECLARE @M VARCHAR(400) = CONCAT('Updated Repair [ID=', @RepairID, '] to ''', @Repair, '''');
	EXEC	Employee.LogModification 
			@SessionID, 
			@AppointmentID, 
			@M;

	COMMIT TRANSACTION;
END;
GO

DROP PROCEDURE Appointment.GetRepairs;
GO

CREATE PROCEDURE Appointment.GetRepairs (
	@SessionID		CHAR(36) = NULL,
	@AppointmentID	UNIQUEIDENTIFIER
)
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	BEGIN TRANSACTION;

	IF (USER_NAME() = 'Customer')
	BEGIN
		EXEC	Appointment.AuthorizeSession 
				@SessionID, 
				@AppointmentID;
	END;

	SELECT		RepairID,
				Repair
	FROM		Appointment.Repair
	WHERE		AppointmentID = @AppointmentID
	ORDER BY	RepairID ASC;

	COMMIT TRANSACTION;
END;
GO