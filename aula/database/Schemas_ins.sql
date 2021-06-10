DELETE FROM Person;
DELETE FROM Student;
DELETE FROM Teacher;
DELETE FROM Guardian;
DELETE FROM GuardedBy;
DELETE FROM Bundle;
DELETE FROM BundledWith;
DELETE FROM MessageThread;
DELETE FROM CommunicatesWith;
DELETE FROM Message;
DROP TRIGGER IF EXISTS checkBundleAdmin ON Bundle;

--------------------------------------
--    Procedures for inserting      --
--------------------------------------

CREATE OR REPLACE PROCEDURE insertBundle (
	bundleName		Bundle.name%TYPE,
	admin_username	Person.username%TYPE,
	offi			BOOLEAN
)
LANGUAGE SQL
AS $$
	INSERT INTO public.Bundle(adminID, name, isOfficial)
	SELECT id, bundleName, offi
	FROM Person
	WHERE username = admin_username
$$;


--------------------------------------
--  Triggers to handle constraints  --
--------------------------------------

CREATE OR REPLACE FUNCTION checkOfficial()
returns TRIGGER
AS $$
	BEGIN
		IF
			new.isOfficial AND
			EXISTS (SELECT *
					FROM Teacher
					WHERE Teacher.id = new.adminID)
		THEN
			return new;
		ELSE
			RAISE EXCEPTION 'Official groups must be run by teachers!';
		END IF;
	END;
$$ language plpgsql;


CREATE TRIGGER checkBundleAdmin
BEFORE INSERT OR UPDATE OF isOfficial ON Bundle
FOR EACH ROW
	EXECUTE PROCEDURE checkOfficial();





--------------------------------------
--    Example database insert       --
--------------------------------------

INSERT INTO public.Person(name, username, password) VALUES ('Jan', 'jan1234', '$2b$12$KFkp1IEMGT4QrWwjPGhE3ejOv6Z3pYhx/S4qOoFbanR2sMiZqgeJO'); -- far
INSERT INTO public.Person(name, username, password) VALUES ('Carl', 'carl1234', '$2b$12$KFkp1IEMGT4QrWwjPGhE3ejOv6Z3pYhx/S4qOoFbanR2sMiZqgeJO'); -- barn
INSERT INTO public.Person(name, username, password) VALUES ('Louise', 'username', '$2b$12$KFkp1IEMGT4QrWwjPGhE3ejOv6Z3pYhx/S4qOoFbanR2sMiZqgeJO'); -- mor
INSERT INTO public.Person(name, username, password) VALUES ('Inger', 'SuperMANN1234@gmail.com', '$2b$12$KFkp1IEMGT4QrWwjPGhE3ejOv6Z3pYhx/S4qOoFbanR2sMiZqgeJO'); -- lærer

INSERT INTO public.Student(id, school)
	SELECT id, 'Sandkassehaven 69'
	FROM Person
	WHERE username = 'carl1234';

INSERT INTO public.Guardian(id)
	SELECT id
	FROM Person
	WHERE username = 'jan1234';
INSERT INTO public.Guardian(id)
	SELECT id
	FROM Person
	WHERE username = 'username';

WITH guardID AS
	(SELECT id FROM Person WHERE username = 'jan1234')
INSERT INTO public.GuardedBy(studentID, guardianID)
	SELECT Person.id, guardID.id
	FROM Person, guardID
	WHERE person.username = 'carl1234';

WITH guardID AS
	(SELECT id FROM Person WHERE username = 'username')
INSERT INTO public.GuardedBy(studentID, guardianID)
	SELECT Person.id, guardID.id
	FROM Person, guardID
	WHERE person.username = 'carl1234';

INSERT INTO public.Teacher(id, school)
	SELECT id, 'Sandkassehaven 69'
	FROM Person
	WHERE username='SuperMANN1234@gmail.com';


CALL insertBundle ( '1. klasse', 'SuperMANN1234@gmail.com', TRUE);

INSERT INTO public.BundledWith(bundleID, personID)
	SELECT Bundle.bundleID, Person.id
	FROM Bundle, Person
	WHERE Bundle.name = '1. klasse' AND Person.username = 'carl1234';

INSERT INTO public.BundledWith(bundleID, personID)
	SELECT Bundle.bundleID, Person.id
	FROM Bundle, Person
	WHERE Bundle.name = '1. klasse' AND Person.username = 'SuperMANN1234@gmail.com';
