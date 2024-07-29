USE WALTRONICS;
GO

CREATE ROLE Customer;

REVOKE	ALTER,
		DELETE,
		EXECUTE,
		INSERT,
		SELECT,
		UPDATE,
		REFERENCES
TO		Customer;

GRANT	EXEC
ON		Appointment.GetSummary
TO		Customer;

GRANT	EXEC
ON		Appointment.GetCustomerNotes
TO		Customer;

GRANT	EXEC
ON		Appointment.AuthenticateSession
TO		Customer;

GRANT	EXEC
ON		Appointment.AuthenticateLookup
TO		Customer;

GRANT	EXEC
ON		Schema::Info
TO		Customer;

ALTER ROLE Customer
ADD MEMBER User_Customer;