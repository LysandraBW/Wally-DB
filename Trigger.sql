USE WALTRONICS;
GO

CREATE TRIGGER Customer.TriggerCustomer
ON Customer.Customer
AFTER UPDATE, INSERT
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @AppointmentID AS UNIQUEIDENTIFIER

	SELECT	@AppointmentID = AppointmentID
	FROM	Appointment.ID 
	WHERE	EXISTS (
				SELECT	1
				FROM	inserted
				WHERE	inserted.CustomerID = Appointment.ID.CustomerID
			)

	UPDATE	Appointment.Date
	SET		UpdationDate = GETDATE()
	WHERE	AppointmentID = @AppointmentID
END
GO

CREATE TRIGGER Appointment.TriggerDate
ON Appointment.Date
AFTER UPDATE, INSERT
AS
BEGIN
	UPDATE	Appointment.Date
	SET		UpdationDate = GETDATE()
	WHERE	EXISTS (
				SELECT	1
				FROM	inserted
				WHERE	inserted.AppointmentID = Appointment.Date.AppointmentID
	)
END
GO

CREATE TRIGGER Appointment.TriggerStatus
ON Appointment.Status
AFTER UPDATE, INSERT
AS
BEGIN
	UPDATE	Appointment.Date
	SET		UpdationDate = GETDATE()
	WHERE	EXISTS (
				SELECT	1
				FROM	inserted
				WHERE	inserted.AppointmentID = Appointment.Date.AppointmentID
	)
END
GO

CREATE TRIGGER Appointment.TriggerVehicle
ON Appointment.Vehicle
AFTER UPDATE, INSERT
AS
BEGIN
	UPDATE	Appointment.Date
	SET		UpdationDate = GETDATE()
	WHERE	EXISTS (
				SELECT	1
				FROM	inserted
				WHERE	inserted.AppointmentID = Appointment.Date.AppointmentID
	)
END
GO

CREATE TRIGGER Appointment.TriggerService
ON Appointment.Service
AFTER UPDATE, INSERT
AS
BEGIN
	UPDATE	Appointment.Date
	SET		UpdationDate = GETDATE()
	WHERE	EXISTS (
				SELECT	1
				FROM	inserted
				WHERE	inserted.AppointmentID = Appointment.Date.AppointmentID
	)
END
GO

CREATE TRIGGER Appointment.TriggerPayment
ON Appointment.Payment
AFTER UPDATE, INSERT
AS
BEGIN
	UPDATE	Appointment.Date
	SET		UpdationDate = GETDATE()
	WHERE	EXISTS (
				SELECT	1
				FROM	inserted
				WHERE	inserted.AppointmentID = Appointment.Date.AppointmentID
	)
END
GO

CREATE TRIGGER Appointment.TriggerCost
ON Appointment.Cost
AFTER UPDATE, INSERT
AS
BEGIN
	UPDATE	Appointment.Date
	SET		UpdationDate = GETDATE()
	WHERE	EXISTS (
				SELECT	1
				FROM	inserted
				WHERE	inserted.AppointmentID = Appointment.Date.AppointmentID
	)
END
GO

CREATE TRIGGER Appointment.TriggerPart
ON Appointment.Part
AFTER UPDATE, INSERT
AS
BEGIN
	UPDATE	Appointment.Date
	SET		UpdationDate = GETDATE()
	WHERE	EXISTS (
				SELECT	1
				FROM	inserted
				WHERE	inserted.AppointmentID = Appointment.Date.AppointmentID
	)
END
GO

CREATE TRIGGER Appointment.TriggerDiagnosis
ON Appointment.Diagnosis
AFTER UPDATE, INSERT
AS
BEGIN
	UPDATE	Appointment.Date
	SET		UpdationDate = GETDATE()
	WHERE	EXISTS (
				SELECT	1
				FROM	inserted
				WHERE	inserted.AppointmentID = Appointment.Date.AppointmentID
	)
END
GO

CREATE TRIGGER Appointment.TriggerFix
ON Appointment.Fix
AFTER UPDATE, INSERT
AS
BEGIN
	UPDATE	Appointment.Date
	SET		UpdationDate = GETDATE()
	WHERE	EXISTS (
				SELECT	1
				FROM	inserted
				WHERE	inserted.AppointmentID = Appointment.Date.AppointmentID
	)
END
GO

CREATE TRIGGER Appointment.TriggerCreditCard
ON Appointment.CreditCard
AFTER UPDATE, INSERT
AS
BEGIN
	DECLARE @AppointmentID AS UNIQUEIDENTIFIER

	SELECT	@AppointmentID = AppointmentID
	FROM	Appointment.Payment 
	WHERE	EXISTS (
				SELECT	1
				FROM	inserted
				WHERE	inserted.PaymentID = Appointment.Payment.PaymentID
			)

	UPDATE	Appointment.Date
	SET		UpdationDate = GETDATE()
	WHERE	AppointmentID = @AppointmentID
END
GO

CREATE TRIGGER Appointment.TriggerNote
ON Appointment.Note
AFTER UPDATE, INSERT
AS
BEGIN
	UPDATE	Appointment.Note
	SET		UpdationDate = GETDATE()
	WHERE	NoteID = (SELECT NoteID FROM inserted)
END
GO

CREATE TRIGGER Appointment.TriggerNoteAttachment
ON Appointment.NoteAttachment
AFTER UPDATE, INSERT
AS
BEGIN
	UPDATE	Appointment.Note
	SET		UpdationDate = GETDATE()
	WHERE	NoteID = (SELECT NoteID FROM inserted)
END
GO