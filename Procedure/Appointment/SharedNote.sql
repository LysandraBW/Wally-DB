USE WALTRONICS;
GO

DROP PROCEDURE Appointment.InsertNoteSharee;
GO

CREATE PROCEDURE Appointment.InsertNoteSharee (
	@SessionID		CHAR(36),
	@NoteID			INT,
	@NoteShareeID	UNIQUEIDENTIFIER
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
		;THROW 50000, 'NOT AN OWNER', 1;
	END;

	IF (@NoteOwnerID = @NoteShareeID)
	BEGIN
		;THROW 50000, 'SHAREE CANNOT BE THE OWNER', 1;
	END;

	INSERT INTO Appointment.SharedNote VALUES (
		@NoteID,
		@NoteShareeID
	);

	COMMIT TRANSACTION;
END
GO

DROP PROCEDURE Appointment.DeleteNoteSharee;
GO

CREATE PROCEDURE Appointment.DeleteNoteSharee (
	@SessionID		CHAR(36),
	@NoteID			INT,
	@NoteShareeID	UNIQUEIDENTIFIER
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
	IF (@NoteShareeID = @SessionEmployeeID)
	BEGIN
		DELETE FROM	Appointment.SharedNote
		WHERE		NoteID		= @NoteID AND
					EmployeeID	= @SessionEmployeeID;
	END;
	-- Removing Someone Else
	ELSE
	BEGIN
		DECLARE @NoteOwnerID UNIQUEIDENTIFIER;
		SELECT	@NoteOwnerID = EmployeeID
		FROM	Appointment.Note
		WHERE	NoteID		= @NoteID AND
				EmployeeID	= @SessionEmployeeID;

		IF (@SessionEmployeeID <> @NoteOwnerID)
		BEGIN
			;THROW 50000, 'MUST BE EVENT OWNER', 1;
		END;

		DELETE FROM	Appointment.SharedNote
		WHERE		NoteID		= @NoteID AND
					EmployeeID	= @NoteShareeID;
	END;

	COMMIT TRANSACTION;
END;
GO

DROP PROCEDURE Appointment.GetNoteSharees;
GO

CREATE PROCEDURE Appointment.GetNoteSharees (
	@SessionID	CHAR(36),
	@NoteID		INT
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

	SELECT		Employee.Employee.FName	AS ShareeFName,
				Employee.Employee.LName	AS ShareeLName,
				Employee.Employee.EmployeeID AS ShareeID
	FROM		Appointment.SharedNote
	JOIN		Employee.Employee ON Appointment.SharedNote.EmployeeID = Employee.Employee.EmployeeID
	JOIN		Appointment.Note ON Appointment.Note.NoteID = Appointment.SharedNote.NoteID
	WHERE		Appointment.Note.NoteID	= @NoteID AND
				Appointment.Note.EmployeeID = @SessionEmployeeID
	ORDER BY	ShareeFName ASC,
				ShareeLName ASC;

	COMMIT TRANSACTION;
END;
GO