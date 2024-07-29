USE WALTRONICS;
GO

DROP PROCEDURE Employee.LogModification;
GO

CREATE PROCEDURE Employee.LogModification (
	@SessionID		CHAR(36),
	@AppointmentID	UNIQUEIDENTIFIER,
	@Modification	VARCHAR(400)
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

	IF (@SessionEmployeeID IS NULL)
	BEGIN
		;THROW 50000, 'UNAUTHORIZED SESSION', 1;
	END;

	INSERT INTO Employee.Modification 
	VALUES (
		@SessionEmployeeID,
		@AppointmentID,
		@Modification,
		GETDATE()
	);

	COMMIT TRANSACTION;
END;
GO

DROP PROCEDURE Employee.Get;
GO

CREATE PROCEDURE Employee.Get (
	@SessionID	CHAR(36)
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

	IF (@SessionEmployeeID IS NULL)
	BEGIN
		;THROW 50000, 'UNAUTHORIZED SESSION', 1;
	END;

	SELECT	Employee.Employee.EmployeeID,
			Employee.Employee.FName,
			Employee.Employee.LName,
			Employee.Employee.Email,
			Employee.Employee.Phone
	FROM	Employee.Employee
	WHERE	Employee.Employee.EmployeeID = @SessionEmployeeID;

	COMMIT TRANSACTION;
END;
GO

DROP PROCEDURE Employee.GetAll;
GO

CREATE PROCEDURE Employee.GetAll (
	@SessionID	CHAR(36)
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

	IF (@SessionEmployeeID IS NULL)
	BEGIN
		;THROW 50000, 'UNAUTHORIZED SESSION', 1;
	END;

	SELECT	Employee.EmployeeID,
			Employee.FName,
			Employee.LName
	FROM	Employee.Employee;

	COMMIT TRANSACTION;
END;
GO