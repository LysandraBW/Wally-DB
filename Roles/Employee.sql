USE WALTRONICS;
GO

CREATE ROLE Employee;

REVOKE	ALTER,
		DELETE,
		EXECUTE,
		INSERT,
		SELECT,
		UPDATE,
		REFERENCES
TO		Employee;

GRANT	EXEC
ON		Schema::Employee		
TO		Employee;

GRANT	EXEC
ON		Schema::Info
TO		Employee;

GRANT	EXEC
ON		Schema::Appointment
TO		Employee;

GRANT	EXEC
ON		Appointment.InsertPayment
TO		Employee;

GRANT	EXEC
ON		Schema::Customer
TO		Employee;

ALTER ROLE Employee
ADD MEMBER User_Employee;