USE WALTRONICS;
GO

DROP PROCEDURE Appointment.InsertNote;
GO

CREATE PROCEDURE Appointment.InsertNote (
	@SessionID		CHAR(36),
	@AppointmentID	UNIQUEIDENTIFIER,
	@Head			VARCHAR(100),
	@Body			VARCHAR(500),
	@ShowCustomer	BIT			 = 0
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


	INSERT INTO Appointment.Note 
	VALUES (
		@SessionEmployeeID, 
		@AppointmentID, 
		@Head, 
		@Body, 
		@ShowCustomer,
		GETDATE(), 
		GETDATE()
	);

	SELECT SCOPE_IDENTITY() AS NoteID;

	COMMIT TRANSACTION;
END;
GO

DROP PROCEDURE Appointment.InsertNoteAttachment;
GO

CREATE PROCEDURE Appointment.InsertNoteAttachment (
	@SessionID	CHAR(36),
	@NoteID		INT,
	@Name		VARCHAR(100),
	@Type		VARCHAR(100),
	@URL		VARCHAR(500)
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


	INSERT INTO Appointment.NoteAttachment (NoteID, Type, Name, URL)
	VALUES (
		@NoteID,
		@Type,
		@Name,
		@URL
	);

	SELECT SCOPE_IDENTITY() AS AttachmentID;

	COMMIT TRANSACTION;
END;
GO

DROP PROCEDURE Appointment.DeleteNote;
GO

CREATE PROCEDURE Appointment.DeleteNote (
	@SessionID		CHAR(36),
	@AppointmentID	UNIQUEIDENTIFIER,
	@NoteID			INT
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

	DECLARE @NoteOwnerID UNIQUEIDENTIFIER;
	SELECT	@NoteOwnerID = EmployeeID
	FROM	Appointment.Note
	WHERE	NoteID = @NoteID;

	IF (@NoteOwnerID <> @SessionEmployeeID)
	BEGIN
		;THROW 50000, 'MUST BE NOTE OWNER', 1;
	END;

	DELETE FROM	Appointment.Note
	WHERE		NoteID			= @NoteID AND
				EmployeeID		= @SessionEmployeeID AND
				AppointmentID	= @AppointmentID;

	COMMIT TRANSACTION;
END;
GO

DROP PROCEDURE Appointment.DeleteNoteAttachment;
GO

CREATE PROCEDURE Appointment.DeleteNoteAttachment (
	@SessionID		CHAR(36),
	@NoteID			INT,
	@AttachmentID	INT
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

	DECLARE @NoteOwnerID UNIQUEIDENTIFIER;
	SELECT	@NoteOwnerID = EmployeeID
	FROM	Appointment.Note
	WHERE	NoteID = @NoteID;

	IF (@NoteOwnerID <> @SessionEmployeeID)
	BEGIN
		;THROW 50000, 'MUST BE NOTE OWNER', 1;
	END;

	DELETE FROM	Appointment.NoteAttachment
	WHERE		NoteID			= @NoteID AND
				AttachmentID	= @AttachmentID;

	COMMIT TRANSACTION;
END;
GO

DROP PROCEDURE Appointment.UpdateNote;
GO

CREATE PROCEDURE Appointment.UpdateNote (
	@SessionID		CHAR(36),
	@AppointmentID	UNIQUEIDENTIFIER,
	@NoteID			INT,
	@Head			VARCHAR(100) = NULL,
	@Body			VARCHAR(500) = NULL,
	@ShowCustomer	BIT		= NULL
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

	DECLARE @NoteOwnerID UNIQUEIDENTIFIER = (
		SELECT	EmployeeID 
		FROM	Appointment.Note 
		WHERE	NoteID = @NoteID
	);

	IF (@NoteOwnerID <> @SessionEmployeeID)
	BEGIN
		;THROW 50000, 'MUST BE NOTE OWNER', 1;
	END;

	IF (@Head IS NOT NULL)
	BEGIN
		UPDATE	Appointment.Note
		SET		Head = @Head
		WHERE	NoteID = @NoteID;
	END;

	IF (@Body IS NOT NULL)
	BEGIN
		UPDATE	Appointment.Note
		SET		Body = @Body
		WHERE	NoteID = @NoteID;
	END;

	IF (@ShowCustomer IS NOT NULL)
	BEGIN
		UPDATE	Appointment.Note
		SET		ShowCustomer = @ShowCustomer
		WHERE	NoteID	= @NoteID;
	END;

	COMMIT TRANSACTION;
END;
GO

DROP PROCEDURE Appointment.GetEmployeeNotes;
GO

CREATE PROCEDURE Appointment.GetEmployeeNotes (
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

	SELECT		DISTINCT
				Appointment.Note.*,
				Employee.FName		AS OwnerFName,
				Employee.LName		AS OwnerLName,
				Employee.EmployeeID AS OwnerID
	FROM		Appointment.Note
	JOIN		Employee.Employee ON Appointment.Note.EmployeeID = Employee.Employee.EmployeeID
	WHERE		Appointment.Note.AppointmentID	= @AppointmentID AND
				Appointment.Note.EmployeeID		= @SessionEmployeeID
	UNION
	SELECT		Appointment.Note.*,
				Employee.FName		AS OwnerFName,
				Employee.LName		AS OwnerLName,
				Employee.EmployeeID AS OwnerID
	FROM		Appointment.Note
	JOIN		Appointment.SharedNote ON Appointment.Note.NoteID = Appointment.SharedNote.NoteID
	JOIN		Employee.Employee ON Appointment.Note.EmployeeID = Employee.Employee.EmployeeID
	WHERE		Appointment.SharedNote.EmployeeID = @SessionEmployeeID AND
				Appointment.Note.AppointmentID = @AppointmentID
	ORDER BY	UpdationDate DESC;

	SELECT	DISTINCT
			URL,
			Name,
			Appointment.Note.NoteID,
			Appointment.NoteAttachment.AttachmentID
	FROM	Appointment.NoteAttachment
	JOIN	Appointment.Note
	ON		Appointment.NoteAttachment.NoteID = Appointment.Note.NoteID
	WHERE	Appointment.Note.AppointmentID = @AppointmentID AND
			Appointment.Note.EmployeeID = @SessionEmployeeID
	UNION
	SELECT	URL,
			Name,
			Appointment.Note.NoteID,
			Appointment.NoteAttachment.AttachmentID
	FROM	Appointment.Note
	JOIN	Appointment.SharedNote ON Appointment.Note.NoteID = Appointment.SharedNote.NoteID
	JOIN	Appointment.NoteAttachment ON Appointment.NoteAttachment.NoteID = Appointment.SharedNote.NoteID
	WHERE	Appointment.SharedNote.EmployeeID = @SessionEmployeeID
	
	COMMIT TRANSACTION;
END;
GO

DROP PROCEDURE Appointment.GetCustomerNotes;
GO

CREATE PROCEDURE Appointment.GetCustomerNotes (
	@SessionID		CHAR(36),
	@AppointmentID	UNIQUEIDENTIFIER
)
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	BEGIN TRANSACTION;

	EXEC	Appointment.AuthorizeSession 
			@SessionID, 
			@AppointmentID;

	SELECT		*
	FROM		Appointment.Note
	WHERE		AppointmentID	= @AppointmentID AND
				ShowCustomer	= 1
	ORDER BY	UpdationDate DESC;

	SELECT		DISTINCT
				URL,
				Name,
				AttachmentID,
				Appointment.Note.NoteID
	FROM		Appointment.NoteAttachment
	JOIN		Appointment.Note
	ON			Appointment.NoteAttachment.NoteID = Appointment.Note.NoteID
	WHERE		Appointment.Note.ShowCustomer = 1

	COMMIT TRANSACTION;
END;
GO