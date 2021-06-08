DROP TABLE IF EXISTS PersonMessage;
DROP TABLE IF EXISTS PersonBundle;
DROP TABLE IF EXISTS Bundle;
DROP TABLE IF EXISTS Teacher;
DROP TABLE IF EXISTS Guardian CASCADE;
DROP TABLE IF EXISTS Student;
DROP TABLE IF EXISTS Person;
DROP TABLE IF EXISTS Message;


----------------------------------------
--            Basic schemas           --
----------------------------------------
CREATE TABLE IF NOT EXISTS Message(
	id		INTEGER GENERATED ALWAYS AS IDENTITY,
	file		VARCHAR(120),
	isImportant	BOOLEAN,
	isSensitive	BOOLEAN,
	date		DATE NOT NULL DEFAULT CURRENT_TIMESTAMP,
	subject		TEXT,
	text		TEXT,
	PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS Person(
	id		INTEGER GENERATED ALWAYS AS IDENTITY,
	name		VARCHAR(120),
	username	VARCHAR(120) UNIQUE NOT NULL,
	password	VARCHAR(120) NOT NULL,
	PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS Student(
	id		INTEGER,
	guardian_id	INTEGER,
	school		VARCHAR(120),
	PRIMARY KEY (id, guardian_id)
);
ALTER TABLE Student ADD FOREIGN KEY (id)
	REFERENCES Person(id) ON DELETE CASCADE;


CREATE TABLE IF NOT EXISTS Guardian(
	id		INTEGER,
	student_id	INTEGER,
	PRIMARY KEY (id, student_id)
);
ALTER TABLE Guardian ADD FOREIGN KEY (id)
	REFERENCES Person(id) ON DELETE CASCADE;
ALTER TABLE Guardian ADD FOREIGN KEY (student_id, id)
	REFERENCES Student(id, guardian_id) ON DELETE CASCADE;

-- Below is set here, as we need to create Guardian before we can reference it.
ALTER TABLE Student ADD FOREIGN KEY (guardian_id, id)
	REFERENCES Guardian(id, student_id) ON DELETE CASCADE;

CREATE TABLE IF NOT EXISTS Teacher(
	id		INTEGER,
	school		VARCHAR(120),
	PRIMARY KEY (id, school)
);
ALTER TABLE Teacher ADD FOREIGN KEY (id)
	REFERENCES Person(id) ON DELETE CASCADE;

CREATE TABLE IF NOT EXISTS Bundle(
	g_id		INTEGER GENERATED ALWAYS AS IDENTITY,
	a_id		INTEGER,
	name		VARCHAR(50),
	isOfficial	BOOLEAN,
	PRIMARY KEY (g_id)
);
ALTER TABLE Bundle ADD FOREIGN KEY (a_id)
	REFERENCES Person(id) ON DELETE SET NULL;


----------------------------------------
--        relational schemas          --
----------------------------------------

CREATE TABLE IF NOT EXISTS PersonBundle(
	g_id		INTEGER,
	u_id		INTEGER,
	PRIMARY KEY (g_id, u_id)
);
ALTER TABLE PersonBundle ADD FOREIGN KEY (g_id)
	REFERENCES Bundle(g_id) ON DELETE CASCADE;
ALTER TABLE PersonBundle ADD FOREIGN KEY (u_id)
	REFERENCES Person(id) ON DELETE CASCADE;

CREATE TABLE IF NOT EXISTS PersonMessage(
	m_id		INTEGER,
	u_id		INTEGER,
	readState	BOOLEAN,
	PRIMARY KEY (m_id, u_id)
);
ALTER TABLE PersonMessage ADD FOREIGN KEY (m_id)
	REFERENCES Message(id) ON DELETE CASCADE;
ALTER TABLE PersonMessage ADD FOREIGN KEY (u_id)
	REFERENCES Person(id) ON DELETE CASCADE;

------------------------------------------------------
-- VIEWS ---------------------------------------------
------------------------------------------------------