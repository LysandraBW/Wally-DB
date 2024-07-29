USE WALTRONICS;
GO

DROP PROCEDURE Appointment.UpdateService;
GO

CREATE PROCEDURE Appointment.UpdateService (
	@SessionID		CHAR(36),
	@AppointmentID	UNIQUEIDENTIFIER,
	@ServiceID		INT,
	@Service		VARCHAR(50) = NULL,
	@Division		VARCHAR(50) = NULL,
	@Class			VARCHAR(50) = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
	SET	XACT_ABORT ON;
	BEGIN TRANSACTION;

	DECLARE @SessionEmployeeID UNIQUEIDENTIFIER;
	EXEC	Employee.AuthenticateSession 
			@SessionID, 
			@SessionEmployeeID OUTPUT;

	IF (@Service IS NOT NULL)
	BEGIN
		UPDATE	Appointment.Service
		SET		Service = @Service
		WHERE	ServiceID		= @ServiceID AND
				AppointmentID	= @AppointmentID;

		DECLARE @M1 VARCHAR(400) = CONCAT('Updated Service to ''', @Service, '''');
		EXEC	Employee.LogModification 
				@SessionID, 
				@AppointmentID, 
				@M1;
	END;

	IF (@Division IS NOT NULL)
	BEGIN
		UPDATE	Appointment.Service
		SET		Division = @Division
		WHERE	ServiceID		= @ServiceID AND
				AppointmentID	= @AppointmentID;

		DECLARE @M2 VARCHAR(400) = CONCAT('Updated Service Division to ''', @Division, '''');
		EXEC	Employee.LogModification 
				@SessionID, 
				@AppointmentID, 
				@M2;
	END;

	IF (@Class IS NOT NULL)
	BEGIN
		UPDATE	Appointment.Service
		SET		Class = @Class
		WHERE	ServiceID		= @ServiceID AND
				AppointmentID	= @AppointmentID;

		DECLARE @M3 VARCHAR(400) = CONCAT('Updated Service Class to ''', @Class, '''');
		EXEC	Employee.LogModification 
				@SessionID, 
				@AppointmentID, 
				@M3;
	END;

	COMMIT TRANSACTION;
END;
GO

DROP PROCEDURE Appointment.InsertDefinedService;
GO

CREATE PROCEDURE Appointment.InsertDefinedService (
	@SessionID		CHAR(36),
	@AppointmentID	UNIQUEIDENTIFIER,
	@ServiceID		INT
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

	DECLARE @Service VARCHAR(50) = (
		SELECT	Service
		FROM	Info.Service
		WHERE	ServiceID = @ServiceID
	);

	DECLARE @Division VARCHAR(50) = (
		SELECT	Division
		FROM	Info.ServiceDivision
		JOIN	Info.Service 
		ON		Info.ServiceDivision.DivisionID = Info.Service.DivisionID
		WHERE	ServiceID = @ServiceID
	);

	DECLARE @Class VARCHAR(50) = (
		SELECT	Class
		FROM	Info.ServiceClass
		JOIN	Info.ServiceDivision
		ON		Info.ServiceClass.ClassID = Info.ServiceDivision.ClassID
		JOIN	Info.Service
		ON		Info.ServiceDivision.DivisionID = Info.Service.DivisionID
		WHERE	ServiceID = @ServiceID
	);

	INSERT INTO Appointment.Service 
	VALUES (
		@AppointmentID, 
		@Class,
		@Division,
		@Service
	);

	IF (USER_NAME() = 'Employee')
	BEGIN
		DECLARE @SessionEmployeeID UNIQUEIDENTIFIER;
		EXEC	Employee.AuthenticateSession 
				@SessionID, 
				@SessionEmployeeID OUTPUT;

		DECLARE @M1 VARCHAR(400) = CONCAT('Inserted Service ''', @Service, '''');
		EXEC	Employee.LogModification 
				@SessionID, 
				@AppointmentID, 
				@M1;
	END;

	SELECT SCOPE_IDENTITY() AS ServiceID;
	COMMIT TRANSACTION;
END
GO

DROP PROCEDURE Appointment.InsertService;
GO

CREATE PROCEDURE Appointment.InsertService (
	@SessionID		CHAR(36),
	@AppointmentID	UNIQUEIDENTIFIER,
	@Service		VARCHAR(50),
	@Division		VARCHAR(50),
	@Class			VARCHAR(50)
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

	INSERT INTO Appointment.Service 
	VALUES (
		@AppointmentID, 
		@Class,
		@Division,
		@Service
	);

	DECLARE @M1 VARCHAR(400) = CONCAT('Inserted Service ''',@Service, '''');
	EXEC	Employee.LogModification 
			@SessionID, 
			@AppointmentID, 
			@M1;

	SELECT SCOPE_IDENTITY() AS ServiceID;
	COMMIT TRANSACTION;
END;
GO

DROP PROCEDURE Appointment.DeleteService;
GO

CREATE PROCEDURE Appointment.DeleteService (
	@SessionID		CHAR(36),
	@AppointmentID	UNIQUEIDENTIFIER,
	@ServiceID		INT
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

	DECLARE @Service VARCHAR(25) = (
		SELECT	Service 
		FROM	Appointment.Service
		WHERE	ServiceID = @ServiceID
	);

	DELETE FROM	Appointment.Service
	WHERE		AppointmentID	= @AppointmentID AND 
				ServiceID		= @ServiceID;

	DECLARE @M1 VARCHAR(400) = 'Deleted Service ''' + @Service + '''';
	EXEC	Employee.LogModification 
			@SessionID, 
			@AppointmentID, 
			@M1;

	COMMIT TRANSACTION;
END
GO

DROP PROCEDURE Appointment.GetServices;
GO

CREATE PROCEDURE Appointment.GetServices (
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

	SELECT		AppService.Class,
				AppService.Division,
				AppService.Service,
				AppService.AppointmentID,
				AppService.ServiceID AS AppointmentServiceID,
				InfoService.ServiceID AS ServiceID
	FROM		Appointment.Service AppService
	LEFT JOIN	Info.Service InfoService		
	ON			AppService.Service = InfoService.Service
	WHERE		AppointmentID = @AppointmentID
	ORDER BY	Class					ASC,
				Division				ASC,
				InfoService.Service		ASC;

	COMMIT TRANSACTION;
END;
GO