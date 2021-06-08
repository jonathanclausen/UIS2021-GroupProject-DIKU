DELETE FROM Person;
DELETE FROM Student;
DELETE FROM Teacher;
DELETE FROM Guardian;
DELETE FROM Bundle;
DELETE FROM PersonBundle;
DELETE FROM Message;
DELETE FROM PersonMessage;
DROP TRIGGER IF EXISTS checkBundleAdmin ON Bundle;

--------------------------------------
--    Procedures for inserting      --
--------------------------------------

CREATE OR REPLACE PROCEDURE insertStudentGuardianPair (
	schoolName			Student.school%TYPE,
	guardianUsername	Person.username%TYPE,
	studentUsername			Person.username%TYPE
)
LANGUAGE SQL
AS $$
WITH guard_key AS
		(INSERT INTO public.Student(id, guardian_id, school)
		 	SELECT p2.id, p1.id, schoolName
			FROM Person p1, Person p2
			WHERE p1.username=guardianUsername AND p2.username=studentUsername
		 RETURNING id, guardian_id)
INSERT INTO public.Guardian(id, student_id)
	SELECT guard_key.guardian_id, guard_key.id
	FROM guard_key;
$$;

CREATE OR REPLACE PROCEDURE insertBundle (
	bundleName		VARCHAR(120),
	admin_username	Person.username%TYPE,
	offi			BOOLEAN
)
LANGUAGE SQL
AS $$
	INSERT INTO public.Bundle(a_id, name, isOfficial)
	SELECT id, bundleName, offi
	FROM Person
	WHERE username = admin_username
$$;

CREATE OR REPLACE PROCEDURE insertPersonBundle (
	uname		Person.username%TYPE,
	bundlename	Bundle.name%TYPE
)
LANGUAGE SQL
AS $$
	WITH something AS
		(SELECT id FROM Person WHERE username=uname)
	INSERT INTO public.PersonBundle(g_id, u_id)
		SELECT g_id, something.id
		FROM Bundle, something
		WHERE bundle.name=bundlename;
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
					WHERE Teacher.id = new.a_id)
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

INSERT INTO public.Person(name, username, password) VALUES ('B.O.B.', 'byggemand', '$2b$12$KFkp1IEMGT4QrWwjPGhE3ejOv6Z3pYhx/S4qOoFbanR2sMiZqgeJO'); -- far
INSERT INTO public.Person(name, username, password) VALUES ('Will.I.Am', 'airplanelover3000', '$2b$12$KFkp1IEMGT4QrWwjPGhE3ejOv6Z3pYhx/S4qOoFbanR2sMiZqgeJO'); -- barn
INSERT INTO public.Person(name, username, password) VALUES ('Beyonce', 'username', '$2b$12$KFkp1IEMGT4QrWwjPGhE3ejOv6Z3pYhx/S4qOoFbanR2sMiZqgeJO'); -- mor
INSERT INTO public.Person(name, username, password) VALUES ('Inger', 'IngerBabe123@gmail.com', '$2b$12$KFkp1IEMGT4QrWwjPGhE3ejOv6Z3pYhx/S4qOoFbanR2sMiZqgeJO'); -- lærer

CALL insertStudentGuardianPair('Sandkassehaven 69', 'byggemand', 'airplanelover3000');
CALL insertStudentGuardianPair('Sandkassehaven 69', 'username', 'airplanelover3000');


INSERT INTO public.Teacher(id, school)
	SELECT id, 'Sandkassehaven 69'
	FROM Person
	WHERE username='IngerBabe123@gmail.com';


CALL insertBundle ( '1. klasse', 'IngerBabe123@gmail.com', TRUE);

CALL insertPersonBundle ('airplanelover3000', '1. klasse');
CALL insertPersonBundle ('IngerBabe123@gmail.com', '1. klasse');

