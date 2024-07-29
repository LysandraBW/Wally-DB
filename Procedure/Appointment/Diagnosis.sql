USE WALTRONICS;
GO

DROP PROCEDURE Appointment.InsertDiagnosis;
GO

CREATE PROCEDURE Appointment.InsertDiagnosis (
	@SessionID		CHAR(36),
	@AppointmentID	UNIQUEIDENTIFIER,
	@Code			VARCHAR(20),
	@Message		VARCHAR(500)
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

	INSERT INTO Appointment.Diagnosis 
	VALUES (
		@AppointmentID,
		@Code,
		@Message
	);

	DECLARE @S1 VARCHAR(300) =	CASE WHEN LEN(@Message) > 300 THEN SUBSTRING(@Message, 1, 300) + '...'
								ELSE @Message END;

	DECLARE @M1 VARCHAR(400) = CONCAT('Inserted Diagnosis ', @Code, ' (''', @S1,''')');
	EXEC	Employee.LogModification 
			@SessionID, 
			@AppointmentID, 
			@M1;

	SELECT SCOPE_IDENTITY() AS DiagnosisID;

	COMMIT TRANSACTION;
END;
GO

DROP PROCEDURE Appointment.DeleteDiagnosis;
GO

CREATE PROCEDURE Appointment.DeleteDiagnosis (
	@SessionID		CHAR(36),
	@AppointmentID	UNIQUEIDENTIFIER,
	@DiagnosisID	INT
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

	DECLARE @Diagnosis VARCHAR(500) = (
		SELECT	Message 
		FROM	Appointment.Diagnosis 
		WHERE	AppointmentID = @AppointmentID AND 
				DiagnosisID = @DiagnosisID
	);

	DELETE FROM Appointment.Diagnosis
	WHERE		AppointmentID	= @AppointmentID AND
				DiagnosisID		= @DiagnosisID;
	
	DECLARE @S1 VARCHAR(300) =	CASE WHEN LEN(@Diagnosis) > 300 THEN SUBSTRING(@Diagnosis, 1, 300) + '...' 
								ELSE @Diagnosis END;

	DECLARE @M1 VARCHAR(400) = 'Deleted Diagnosis ''' + @S1 + '''';
	EXEC	Employee.LogModification 
			@SessionID, 
			@AppointmentID, 
			@M1;

	COMMIT TRANSACTION;
END;
GO

DROP PROCEDURE Appointment.UpdateDiagnosis;
GO

CREATE PROCEDURE Appointment.UpdateDiagnosis (
	@SessionID		CHAR(36),
	@AppointmentID	UNIQUEIDENTIFIER,
	@DiagnosisID	INT,
	@Code			VARCHAR(20)		= NULL,
	@Message		VARCHAR(500)	= NULL
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
	
	IF (@Code IS NOT NULL)
	BEGIN
		UPDATE	Appointment.Diagnosis
		SET		Code = @Code
		WHERE	AppointmentID	= @AppointmentID AND
				DiagnosisID		= @DiagnosisID;

		DECLARE @M1 VARCHAR(400) = CONCAT('Updated Diagnosis [ID=', @DiagnosisID, '] Code to ''', @Code, '''');
		EXEC	Employee.LogModification 
				@SessionID, 
				@AppointmentID, 
				@M1;
	END;

	IF (@Message IS NOT NULL)
	BEGIN
		UPDATE	Appointment.Diagnosis
		SET		Message = @Message
		WHERE	AppointmentID	= @AppointmentID AND
				DiagnosisID		= @DiagnosisID;

		DECLARE @S1 VARCHAR(300) =	CASE WHEN LEN(@Message) > 300 THEN SUBSTRING(@Message, 1, 300) + '...'
									ELSE @Message END;

		DECLARE @M2 VARCHAR(400) = CONCAT('Updated Diagnosis [ID=', @DiagnosisID, '] Message to ''', @S1, '''');
		EXEC	Employee.LogModification 
				@SessionID, 
				@AppointmentID, 
				@M2;
	END;

	COMMIT TRANSACTION;
END;
GO

DROP PROCEDURE Appointment.GetDiagnoses;
GO

CREATE PROCEDURE Appointment.GetDiagnoses (
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

	SELECT		DiagnosisID,
				Code,
				Message
	FROM		Appointment.Diagnosis
	WHERE		AppointmentID = @AppointmentID
	ORDER BY	DiagnosisID ASC;

	COMMIT TRANSACTION;
END;
GO