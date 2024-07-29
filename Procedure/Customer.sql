USE WALTRONICS;
GO

DROP PROCEDURE Customer.UpdateCustomer;
GO

CREATE PROCEDURE Customer.UpdateCustomer (
	@SessionID		CHAR(36),
	@AppointmentID	UNIQUEIDENTIFIER,
	@FName			VARCHAR(50)		=	NULL,
	@LName			VARCHAR(50)		=	NULL,
	@Email			VARCHAR(320)	=	NULL,
	@Phone			VARCHAR(25)		=	NULL
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

	DECLARE @CustomerID UNIQUEIDENTIFIER
	SELECT	@CustomerID = Customer.Customer.CustomerID
	FROM	Customer.Customer
	JOIN	Appointment.ID
	ON		Customer.Customer.CustomerID = Appointment.ID.CustomerID
	WHERE	Appointment.ID.AppointmentID = @AppointmentID;

	IF (@FName IS NOT NULL)
	BEGIN
		UPDATE	Customer.Customer
		SET		FName		= @FName
		WHERE	CustomerID	= @CustomerID;

		DECLARE @M1 VARCHAR(400) = 'Updated Customer FName to ''' + @FName + '''';
		EXEC	Employee.LogModification 
				@SessionID, 
				@AppointmentID, 
				@M1;
	END;

	IF (@LName IS NOT NULL)
	BEGIN
		UPDATE	Customer.Customer
		SET		LName		= @LName
		WHERE	CustomerID	= @CustomerID

		DECLARE @M2 VARCHAR(400) = 'Updated Customer LName to ''' + @LName + '''';
		EXEC	Employee.LogModification 
				@SessionID, 
				@AppointmentID, 
				@M2;
	END;

	IF (@Email IS NOT NULL)
	BEGIN
		UPDATE	Customer.Customer
		SET		Email		= @Email
		WHERE	CustomerID	= @CustomerID;

		DECLARE @M3 VARCHAR(400) = 'Updated Customer Email to ''' + @Email + '''';
		EXEC	Employee.LogModification 
				@SessionID, 
				@AppointmentID, 
				@M3;
	END;

	IF (@Phone IS NOT NULL)
	BEGIN
		UPDATE	Customer.Customer
		SET		Phone = @Phone
		WHERE	CustomerID = @CustomerID;

		DECLARE @M4 VARCHAR(400) = 'Updated Customer Phone to ''' + @Phone + '''';
		EXEC	Employee.LogModification 
				@SessionID, 
				@AppointmentID, 
				@M4
	END;

	COMMIT TRANSACTION;
END;
GO