USE WALTRONICS;
GO

DROP PROCEDURE Appointment.InsertPart;
GO

CREATE PROCEDURE Appointment.InsertPart (
	@SessionID		CHAR(36),
	@AppointmentID	UNIQUEIDENTIFIER, 
	@PartName		VARCHAR(50), 
	@PartNumber		VARCHAR(50), 
	@Quantity		INT, 
	@UnitCost		MONEY
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

	INSERT INTO Appointment.Part 
	VALUES (
		@AppointmentID, 
		@PartName, 
		@PartNumber, 
		@Quantity, 
		@UnitCost
	);

	DECLARE @M1 VARCHAR(400) = 'Inserted Part ''' + @PartName + '''';
	EXEC	Employee.LogModification 
			@SessionID, 
			@AppointmentID, 
			@M1;

	SELECT SCOPE_IDENTITY() AS PartID;

	COMMIT TRANSACTION;
END;
GO

DROP PROCEDURE Appointment.DeletePart;
GO

CREATE PROCEDURE Appointment.DeletePart (
	@SessionID		CHAR(36),
	@AppointmentID	UNIQUEIDENTIFIER,
	@PartID			INT
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

	DECLARE @PartName VARCHAR(50) = (
		SELECT	PartName 
		FROM	Appointment.Part 
		WHERE	PartID = @PartID
	);

	DELETE FROM Appointment.Part
	WHERE		PartID			= @PartID AND
				AppointmentID	= @AppointmentID;

	
	DECLARE @M1 VARCHAR(400) = 'Deleted Part ' + @PartName;
	EXEC	Employee.LogModification 
			@SessionID, 
			@AppointmentID, 
			@M1;

	COMMIT TRANSACTION;
END;
GO

DROP PROCEDURE Appointment.UpdatePart;
GO

CREATE PROCEDURE Appointment.UpdatePart (
	@SessionID		CHAR(36),
	@AppointmentID	UNIQUEIDENTIFIER,
	@PartID			INT, 
	@PartName		VARCHAR(50) = NULL, 
	@PartNumber		VARCHAR(50) = NULL, 
	@Quantity		INT			= NULL, 
	@UnitCost		MONEY		= NULL
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
	
	IF (@PartName IS NOT NULL)
	BEGIN
		UPDATE	Appointment.Part
		SET		PartName = @PartName
		WHERE	PartID			= @PartID AND
				AppointmentID	= @AppointmentID;

		DECLARE @M1 VARCHAR(400) = CONCAT('Updated Part [ID=', @PartID ,'] Name to ''', @PartName, '''');
		EXEC	Employee.LogModification 
				@SessionID, 
				@AppointmentID, 
				@M1;
	END;

	IF (@PartNumber IS NOT NULL)
	BEGIN
		UPDATE	Appointment.Part
		SET		PartNumber = @PartNumber
		WHERE	PartID			= @PartID AND
				AppointmentID	= @AppointmentID;

		DECLARE @M2 VARCHAR(400) = CONCAT('Updated Part [ID=', @PartID ,'] Number to ''', @PartNumber, '''');
		EXEC	Employee.LogModification 
				@SessionID, 
				@AppointmentID, 
				@M2;
	END;

	IF (@Quantity IS NOT NULL)
	BEGIN
		UPDATE	Appointment.Part
		SET		Quantity = @Quantity
		WHERE	PartID			= @PartID AND
				AppointmentID	= @AppointmentID;

		DECLARE @M3 VARCHAR(400) = CONCAT('Updated Part [ID=', @PartID ,'] Quantity to ''', @Quantity, '''');
		EXEC	Employee.LogModification 
				@SessionID, 
				@AppointmentID, 
				@M3;
	END;

	IF (@UnitCost IS NOT NULL)
	BEGIN
		UPDATE	Appointment.Part
		SET		UnitCost = @UnitCost
		WHERE	PartID			= @PartID AND
				AppointmentID	= @AppointmentID;

		DECLARE @M4 VARCHAR(400) = CONCAT('Updated Part[ID=', @PartID ,'] Cost to ''', @UnitCost, '''');
		EXEC	Employee.LogModification 
				@SessionID, 
				@AppointmentID, 
				@M4;
	END;

	COMMIT TRANSACTION;
END;
GO

DROP PROCEDURE Appointment.GetParts;
GO

CREATE PROCEDURE Appointment.GetParts (
	@AppointmentID	UNIQUEIDENTIFIER
)
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	BEGIN TRANSACTION;
	SELECT		PartID, 
				PartName, 
				PartNumber, 
				Quantity, 
				UnitCost
	FROM		Appointment.Part
	WHERE		AppointmentID = @AppointmentID
	ORDER BY	PartID ASC;
	COMMIT TRANSACTION;
END;
GO