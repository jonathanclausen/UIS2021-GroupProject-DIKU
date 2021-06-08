# write all your SQL queries in this file.
from datetime import datetime
from re import search
from aula import conn, login_manager
from flask_login import UserMixin
from psycopg2 import sql

@login_manager.user_loader
def load_user(user_id):
    cur = conn.cursor()

    schema = 'Person'
    id = "username"
    

    user_sql = sql.SQL("""
    SELECT * FROM Person
    WHERE {} = %s
    """).format(sql.Identifier(id))

    cur.execute(user_sql, (str(user_id),))
    if cur.rowcount > 0:
        return Person(cur.fetchone())
    else:
        return None


class Person(tuple, UserMixin):
    def __init__(self, user_data):
        self.id = user_data[0]
        self.name = user_data[1]
        self.username = user_data[2]
        self.password = user_data[3]
    
    def get_key(self):
        return (self.id)
    def get_id(self):
       return (self.username)
    def get_name(self):
        return (self.name)

class Student(Person):
    def __init__(self, user_data):
        Person.__init__(self, user_data)
        self.guardian = user_data[10]
        self.school = user_data[11]

class Guardian(Person):
    def __init__(self, user_data):
        Person.__init__(self, user_data)
        self.student = user_data[10]

class Teacher(Person):
    def __init__(self, user_data):
        Person.__init__(self, user_data)
        self.grades = user_data[10]

def select_Users(username):
    cur = conn.cursor()
    sql = """
    SELECT * FROM Person
    WHERE username = %s
    """
    cur.execute(sql, (username,))
    user = Person(cur.fetchone()) if cur.rowcount > 0 else None;
    cur.close()
    return user

def search_Users(query):
    with conn.cursor() as cur:
        search = query.lower().split(sep=" ")

        sql = """
            SELECT tmp.uname, tmp.gname, tmp.u_id
                FROM ((Person p
                    FULL JOIN PersonBundle pb ON p.id = pb.u_id) ppb
                    FULL JOIN Bundle b ON ppb.g_id = b.g_id)
                    AS tmp (u_id, uname, username, password, g_id, uid, g_id2, a_id, gname, isofficial)
        """

        cur.execute(sql)
        # Below assumes that no group exists with no members!
        result = []
        for record in cur:
            print(record)
            record = (record[0].lower(), record[1].lower() if record[1] is not None else None, record[2])
            isMatch = False
            for key in search:
                if key in record[0] or (record[1] is not None and key in record[1]):
                    isMatch = True
                else:
                    isMatch = False
                    break
            if isMatch:
                result.append(record)
        print(result)
        result = [(elm[2], ' '.join((elm[0], elm[1]))) if all(elm) else (elm[2], elm[0]) for elm in result]
        print ("result of query: " + str(result))
        return result


def get_message_participants(msg_id):
    cur = conn.cursor()
    sql = """
    SELECT name
    FROM personmessage join person
    ON personmessage.U_id = person.id
    WHERE personmessage.m_id = %s
    """
    cur.execute(sql, (msg_id,))
    parts = cur.fetchall() if cur.rowcount > 0 else None;
    cur.close()
    parts = [list(ele) for ele in parts]
    return parts

def get_user_messages(id):
    cur = conn.cursor()
    sql = """
    SELECT id, readstate, file, isimportant, issensitive, date, subject, text FROM personmessage join message 
    ON personmessage.M_id = message.id
    WHERE u_id = %s
    """
    cur.execute(sql, (id,))
    messages = cur.fetchall() if cur.rowcount > 0 else None;
    
    msgs = [list(ele) for ele in messages]

    cur.close()
    for elm in msgs:
        elm.append(get_message_participants(elm[0]))

    return msgs


def send_message_to(message,sender):
    with conn.cursor() as cur:
        recipients = message[0]
        isSensitive = True if message[2] is not None else False
        subject = message[1]
        message = message[3]
        sql = """
            WITH m_key AS
		        (INSERT INTO Message(isSensitive, subject, text)
                    VALUES (%s, %s, %s)
		        RETURNING id),
            forget AS
                (INSERT INTO PersonMessage(m_id, u_id, readState)
                    SELECT m_key.id, %s, FALSE
                    FROM m_key)
            INSERT INTO public.PersonMessage(m_id, u_id, readState)
	            SELECT m_key.id, %s, TRUE
	            FROM m_key
        """
        cur.execute(sql, (isSensitive, subject, message, recipients, sender))
        conn.commit()
        return True

def find_user_groups(id):
    cur = conn.cursor()
    sql = """
    SELECT b.g_id, b.name
    FROM PersonBundle pb
        JOIN Bundle b ON pb.g_id = b.g_id
    WHERE pb.u_id = %s
    """
    
    cur.execute(sql, (id,))

    groups = cur.fetchall()
    #groups = cur.fetchall() if cur.rowcount > 0 else None;

    cur.close()
    return groups
    

