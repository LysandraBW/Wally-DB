USE WALTRONICS;
GO

DROP PROCEDURE Employee.InsertEventSharee;
GO

CREATE PROCEDURE Employee.InsertEventSharee (
	@SessionID		CHAR(36),
	@EventID		INT,
	@EventShareeID	UNIQUEIDENTIFIER
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

	DECLARE @EventOwnerID UNIQUEIDENTIFIER;
	SELECT	@EventOwnerID = EmployeeID
	FROM	Employee.Event
	WHERE	EventID = @EventID;

	IF (@EventOwnerID <> @SessionEmployeeID)
	BEGIN
		;THROW 50000, 'UNAUTHORIZED USER', 1;
	END;

	IF (@EventOwnerID = @EventShareeID)
	BEGIN
		;THROW 50000, 'CANNOT ADD YOURSELF', 1;
	END;

	INSERT INTO Employee.SharedEvent (EventID, EmployeeID)
	VALUES (
		@EventID,
		@EventShareeID
	);

	COMMIT TRANSACTION;
END;
GO

DROP PROCEDURE Employee.DeleteEventSharee;
GO

CREATE PROCEDURE Employee.DeleteEventSharee (
	@SessionID		CHAR(36),
	@EventID		INT,
	@EventShareeID	UNIQUEIDENTIFIER = NULL
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

	-- Removing Yourself
	IF (@EventShareeID IS NULL)
	BEGIN
			DELETE FROM	Employee.SharedEvent
			WHERE		EventID		= @EventID AND
						EmployeeID	= @SessionEmployeeID;
	END;
	-- Removing Someone
	ELSE
	BEGIN
		DECLARE @EventOwnerID UNIQUEIDENTIFIER
		SELECT	@EventOwnerID = EmployeeID
		FROM	Employee.Event
		WHERE	EventID = @EventID;

		IF (@SessionEmployeeID <> @EventOwnerID)
		BEGIN
			;THROW 50000, 'UNAUTHORIZED USER', 1;
		END;
		
		DELETE FROM	Employee.SharedEvent
		WHERE		EventID		= @EventID AND
					EmployeeID	= @EventShareeID;
	END;

	COMMIT TRANSACTION;
END;
GO

DROP PROCEDURE Employee.GetEventSharees;
GO

CREATE PROCEDURE Employee.GetEventSharees (
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

	SELECT		Employee.Employee.FName			AS ShareeFName,
				Employee.Employee.LName			AS ShareeLName,
				Employee.Employee.EmployeeID	AS ShareeID
	FROM		Employee.SharedEvent
	JOIN		Employee.Employee				ON Employee.SharedEvent.EmployeeID = Employee.Employee.EmployeeID
	JOIN		Employee.Event					ON Employee.Event.EventID = Employee.SharedEvent.EventID
	WHERE		Employee.Event.EventID			= @EventID AND
				Employee.Event.EmployeeID		= @SessionEmployeeID
	ORDER BY	ShareeFName ASC,
				ShareeLName ASC;

	COMMIT TRANSACTION;
END;
GO