USE WALTRONICS;
GO

DROP PROCEDURE Employee.AuthenticateLogin;
GO

CREATE PROCEDURE Employee.AuthenticateLogin (
	@Username	VARCHAR(50),
	@Password	VARCHAR(50),
	@SessionID	CHAR(36) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	BEGIN TRANSACTION;

	DECLARE	@EmployeeID UNIQUEIDENTIFIER = (
		SELECT	EmployeeID
		FROM	Employee.Login
		WHERE	Username = @Username AND
				Password = CONVERT(VARCHAR(255), HASHBYTES('SHA2_256', @Password))
	);

	IF (@EmployeeID IS NULL)
	BEGIN
		;THROW 50000, 'EMPLOYEE NOT FOUND', 1;
	END;

	DECLARE @_SessionID CHAR(36);
	EXEC Info.SessionID @_SessionID OUTPUT;

	IF (EXISTS(
			SELECT	1 
			FROM	Employee.Session 
			WHERE	EmployeeID = @EmployeeID
	))
	BEGIN
		UPDATE	Employee.Session
		SET		SessionID = @_SessionID,
				LoginDate = GETDATE()
		WHERE	EmployeeID = @EmployeeID;
	END;
	ELSE
	BEGIN
		INSERT INTO Employee.Session
		VALUES (
			@EmployeeID,
			@_SessionID,
			GETDATE()
		);
	END;

	SELECT @SessionID = @_SessionID;
	COMMIT TRANSACTION;
END;
GO

DROP PROCEDURE Employee.AuthenticateSession;
GO

CREATE PROCEDURE Employee.AuthenticateSession (
	@SessionID CHAR(36),
	@EmployeeID UNIQUEIDENTIFIER OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	BEGIN TRANSACTION;

	DECLARE @_EmployeeID UNIQUEIDENTIFIER = (
		SELECT	EmployeeID
		FROM	Employee.Session
		WHERE	SessionID = @SessionID
	);

	IF (@_EmployeeID IS NULL)
	BEGIN
		;THROW 50000, 'UNAUTHENTICATED SESSION', 1;
	END;

	SELECT @EmployeeID = @_EmployeeID;

	COMMIT TRANSACTION;
END;
GO

DROP PROCEDURE Employee.LogOut;
GO

CREATE PROCEDURE Employee.LogOut (
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

	IF (@SessionEmployeeID IS NULL)
	BEGIN
		;THROW 50000, 'UNAUTHORIZED SESSION', 1;
	END;

	DELETE FROM	Employee.Session
	WHERE		SessionID = @SessionID AND
				EmployeeID = @SessionEmployeeID;

	COMMIT TRANSACTION;
END;
GO