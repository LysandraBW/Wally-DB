USE WALTRONICS;
GO

DROP TABLE Customer.Customer;

CREATE TABLE Customer.Customer (
	CustomerID	UNIQUEIDENTIFIER	NOT NULL DEFAULT NEWSEQUENTIALID(),
	FName		VARCHAR(50)			NOT NULL,
	LName		VARCHAR(50)			NOT NULL,
	Email		VARCHAR(320)		NOT NULL,
	Phone		VARCHAR(25)			NOT NULL,
	CHECK (FName NOT LIKE	'%[^A-Za-z -]%'),
	CHECK (LName NOT LIKE	'%[^A-Za-z -]%'),
	CHECK (Email LIKE		'%[A-Za-z0-9]@[A-Za-z0-9][A-Za-z0-9]%.[A-Za-z0-9][A-Za-z0-9]%'),
	CHECK (Phone NOT LIKE	'%[^0-9-+()]%'),
	PRIMARY KEY (CustomerID)
);

ALTER TABLE Customer.Customer
ADD CONSTRAINT DK_Customer 
DEFAULT NEWSEQUENTIALID() FOR CustomerID;