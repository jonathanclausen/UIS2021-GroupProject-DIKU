DROP TABLE IF EXISTS CommunicatesWith;
DROP TABLE IF EXISTS BundledWith;
DROP TABLE IF EXISTS GuardedBy;
DROP TABLE IF EXISTS Bundle;
DROP TABLE IF EXISTS Teacher;
DROP TABLE IF EXISTS Guardian;
DROP TABLE IF EXISTS Student;
DROP TABLE IF EXISTS Message;
DROP TABLE IF EXISTS Person;
DROP TABLE IF EXISTS MessageThread;


----------------------------------------
--            Basic schemas           --
----------------------------------------
CREATE TABLE IF NOT EXISTS MessageThread(
	id			INTEGER GENERATED ALWAYS AS IDENTITY,
	isImportant	BOOLEAN,
	isSensitive	BOOLEAN,
	PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS Person(
	id			INTEGER GENERATED ALWAYS AS IDENTITY,
	name		VARCHAR(120),
	username	VARCHAR(120) UNIQUE NOT NULL,
	password	VARCHAR(120) NOT NULL,
	PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS Message(
	messageID	INTEGER GENERATED ALWAYS AS IDENTITY,
	threadID	INTEGER,
	senderID	INTEGER,
	subject		TEXT,
	text		TEXT,
	datetime	TIMESTAMP (0) NOT NULL DEFAULT CURRENT_TIMESTAMP,
	file		VARCHAR(120),
	PRIMARY KEY (messageID)
);
ALTER TABLE Message ADD FOREIGN KEY (threadID)
	REFERENCES MessageThread(id) ON DELETE CASCADE;
ALTER TABLE Message ADD FOREIGN KEY (senderID)
	REFERENCES Person(id) ON DELETE SET DEFAULT;

CREATE TABLE IF NOT EXISTS Student(
	id			INTEGER,
	school		VARCHAR(120),
	PRIMARY KEY (id)
);
ALTER TABLE Student ADD FOREIGN KEY (id)
	REFERENCES Person(id) ON DELETE CASCADE;


CREATE TABLE IF NOT EXISTS Guardian(
	id			INTEGER,
	PRIMARY KEY (id)
);
ALTER TABLE Guardian ADD FOREIGN KEY (id)
	REFERENCES Person(id) ON DELETE CASCADE;

CREATE TABLE IF NOT EXISTS Teacher(
	id			INTEGER,
	school		VARCHAR(120),
	PRIMARY KEY (id, school)
);
ALTER TABLE Teacher ADD FOREIGN KEY (id)
	REFERENCES Person(id) ON DELETE CASCADE;

CREATE TABLE IF NOT EXISTS Bundle(
	bundleID	INTEGER GENERATED ALWAYS AS IDENTITY,
	adminID		INTEGER,
	name		VARCHAR(120),
	isOfficial	BOOLEAN,
	PRIMARY KEY (bundleID)
);
ALTER TABLE Bundle ADD FOREIGN KEY (adminID)
	REFERENCES Person(id) ON DELETE SET NULL;


----------------------------------------
--        relational schemas          --
----------------------------------------
CREATE TABLE IF NOT EXISTS GuardedBy(
	studentID	INTEGER,
	guardianID	INTEGER,
	PRIMARY KEY (studentID, guardianID)
);
ALTER TABLE GuardedBy ADD FOREIGN KEY (studentID)
	REFERENCES Person(id) ON DELETE CASCADE;
ALTER TABLE GuardedBy ADD FOREIGN KEY (guardianID)
	REFERENCES Person(id) ON DELETE CASCADE;


CREATE TABLE IF NOT EXISTS BundledWith(
	bundleID	INTEGER,
	personID	INTEGER,
	PRIMARY KEY (bundleID, personID)
);
ALTER TABLE BundledWith ADD FOREIGN KEY (bundleID)
	REFERENCES Bundle(bundleID) ON DELETE CASCADE;
ALTER TABLE BundledWith ADD FOREIGN KEY (personID)
	REFERENCES Person(id) ON DELETE CASCADE;

CREATE TABLE IF NOT EXISTS CommunicatesWith(
	threadID	INTEGER,
	personID	INTEGER,
	readState	BOOLEAN,
	PRIMARY KEY (threadID, personID)
);
ALTER TABLE CommunicatesWith ADD FOREIGN KEY (threadID)
	REFERENCES MessageThread(id) ON DELETE CASCADE;
ALTER TABLE CommunicatesWith ADD FOREIGN KEY (personID)
	REFERENCES Person(id) ON DELETE CASCADE;

------------------------------------------------------
-- VIEWS ---------------------------------------------
------------------------------------------------------