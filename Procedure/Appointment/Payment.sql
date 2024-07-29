USE WALTRONICS;
GO

DROP PROCEDURE Appointment.UpdateCost;
GO

CREATE PROCEDURE Appointment.UpdateCost (
	@SessionID		CHAR(36),
	@AppointmentID	UNIQUEIDENTIFIER,
	@Cost			DECIMAL(10,2)
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

	UPDATE	Appointment.Cost
	SET		Cost			= @Cost
	WHERE	AppointmentID	= @AppointmentID

	DECLARE @M VARCHAR(400) = 'Updated Cost to ''' + CAST(@Cost AS VARCHAR) + '''';
	EXEC	Employee.LogModification 
			@SessionID, 
			@AppointmentID, 
			@M;

	COMMIT TRANSACTION;
END;
GO

DROP PROCEDURE Appointment.InsertPayment;
GO

CREATE PROCEDURE Appointment.InsertPayment (
	@SessionID		CHAR(36),
	@AppointmentID	UNIQUEIDENTIFIER,
	@Payment		MONEY
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

	INSERT INTO Appointment.Payment VALUES (
		@AppointmentID, 
		@Payment, 
		GETDATE()
	);

	DECLARE @M1 VARCHAR(400) = CONCAT('Inserted Payment ''', CAST(@Payment AS VARCHAR), '''');
	EXEC	Employee.LogModification 
			@SessionID, 
			@AppointmentID, 
			@M1;

	SELECT SCOPE_IDENTITY() AS PaymentID;

	COMMIT TRANSACTION;
END;
GO

DROP PROCEDURE Appointment.DeletePayment;
GO

CREATE PROCEDURE Appointment.DeletePayment (
	@SessionID		CHAR(36),
	@AppointmentID	UNIQUEIDENTIFIER,
	@PaymentID		INT
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

	DECLARE @PrevPayment INT = (
		SELECT	Payment 
		FROM	Appointment.Payment 
		WHERE	PaymentID = @PaymentID
	);

	DECLARE @CCN CHAR(4);
	IF (EXISTS(SELECT 1 FROM CreditCard WHERE CreditCard.PaymentID = @PaymentID))
	BEGIN
		SET @CCN = (SELECT CCN FROM	CreditCard WHERE CreditCard.PaymentID = @PaymentID);
	END;
	ELSE
	BEGIN
		SET @CCN = 'N/A';
	END;

	DECLARE @Type VARCHAR(10);
	IF (EXISTS (SELECT 1 FROM CreditCard WHERE CreditCard.PaymentID = @PaymentID))
	BEGIN
		SET @Type = (SELECT	Type FROM CreditCard WHERE CreditCard.PaymentID = @PaymentID);
	END;
	ELSE
	BEGIN
		SET @Type = 'N/A';
	END;

	DELETE FROM	Appointment.Payment
	WHERE		PaymentID		= @PaymentID AND
				AppointmentID	= @AppointmentID;

	DECLARE @M1 VARCHAR(400) = CONCAT('Deleted Payment [ID=', @PaymentID, ' , Type=', @Type, ' , CCN=', @CCN,'] of ''', @PrevPayment, '''');
	EXEC	Employee.LogModification 
			@SessionID, 
			@AppointmentID, 
			@M1;

	COMMIT TRANSACTION;
END;
GO

DROP PROCEDURE Appointment.InsertCreditCard;
GO

CREATE PROCEDURE Appointment.InsertCreditCard (
	@SessionID		CHAR(36),
	@AppointmentID	UNIQUEIDENTIFIER,
	@PaymentID		INT,
	@Name			VARCHAR(100),
	@Type			VARCHAR(10),
	@CCN			CHAR(4),
	@EXP			CHAR(4)
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

	INSERT INTO CreditCard 
	VALUES (
		@PaymentID,
		@Name,
		@Type,
		@CCN,
		@EXP
	);

	IF (@SessionEmployeeID IS NOT NULL)
	BEGIN
		DECLARE @M1 VARCHAR(400) = CONCAT('Attached Credit Card [Type=',@Type,' CCN=',@CCN,'] to ', @PaymentID);
		EXEC	Employee.LogModification 
				@SessionID, 
				@AppointmentID, 
				@M1;
	END;

	COMMIT TRANSACTION;
END;
GO

DROP PROCEDURE Appointment.GetPayments;
GO

CREATE PROCEDURE Appointment.GetPayments (
	@AppointmentID	UNIQUEIDENTIFIER
)
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	BEGIN TRANSACTION;

	SELECT		Appointment.Payment.PaymentID,
				Appointment.Payment.PaymentDate,
				Appointment.Payment.Payment,
				Appointment.CreditCard.CCN,
				Appointment.CreditCard.EXP,
				Appointment.CreditCard.Name,
				Appointment.CreditCard.Type
	FROM		Appointment.Payment
	LEFT JOIN	Appointment.CreditCard
	ON			Appointment.Payment.PaymentID = Appointment.CreditCard.PaymentID
	WHERE		Appointment.Payment.AppointmentID = @AppointmentID
	ORDER BY	Appointment.Payment.PaymentDate;

	COMMIT TRANSACTION;
END;
GO