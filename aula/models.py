# write all your SQL queries in this file.
from datetime import datetime
from re import search
from aula import conn, login_manager
from flask_login import UserMixin, current_user
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

class Group():
    def __init__(self, group_data):
        self.id = (group_data[0])
        self.admin = (group_data[1])
        self.name = (group_data[2])
        self.is_official = (group_data[3])

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
    user = Person(cur.fetchone()) if cur.rowcount > 0 else None
    cur.close()
    return user

def search_Users(query):
    with conn.cursor() as cur:
        search = query.lower().split(sep=" ")

        sql = """
            SELECT tmp.uname, tmp.gname, tmp.u_id
                FROM ((Person p
                    FULL JOIN BundledWith pb ON p.id = pb.personID) ppb
                    FULL JOIN Bundle b ON ppb.bundleID = b.bundleid)
                    AS tmp (u_id, uname, username, password, bundleID, uid, g_id2, a_id, gname, isofficial)
                WHERE tmp.u_id != %s
        """

        cur.execute(sql, (current_user.get_key(),))
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
    with conn.cursor() as cur:
        sql = """
        WITH threads AS 
        (SELECT *
        FROM message
        JOIN  messagethread 
        ON threadID = messagethread.id
        WHERE messageid = %s)

        SELECT DISTINCT name 
            FROM (threads
                JOIN communicatesWith ON threads.threadID = communicatesWith.threadID) tmp
                JOIN PERSON on tmp.personID = person.id OR tmp.senderid = person.id
        """ 
        cur.execute(sql, (msg_id,))
        parts = cur.fetchall() if cur.rowcount > 0 else None
    # removing current user from message participants.
    parts = filter(lambda x : x != current_user.name, [ele[0] for ele in parts]) if parts is not None else []
    return parts

def get_user_messages(id):
    with conn.cursor() as cur:
        sql = """
        SELECT messageID, readState, file, isImportant, isSensitive, datetime, subject, text
        FROM (CommunicatesWith
            JOIN MessageThread ON id = threadID) tmp
            JOIN Message m ON m.threadID = tmp.threadID
        WHERE personid = %s or senderid = %s
        ORDER BY datetime DESC
        """

        cur.execute(sql, (id,id))
        messages = cur.fetchall() if cur.rowcount > 0 else None
        
    msgs = [list(ele) for ele in messages] if messages is not None else []

    for elm in msgs:
        elm.append(get_message_participants(elm[0]))
    return msgs

def get_group_members(group_id):
    with conn.cursor() as cur:
        sql = """
        SELECT personID
        FROM Bundle b
	        JOIN BundledWith bw ON b.bundleID = bw.bundleID
        WHERE b.bundleID = %s
        """
        cur.execute(sql, (group_id,))
        ids = []
        for record in cur:
            ids.append(record[0])
    return ids

def send_message_to(message,sender):
    with conn.cursor() as cur:
        recipients = message[0]
        isSensitive = True if message[2] is not None else False
        subject = message[1]
        message = message[3]

        sql = """
            WITH Thread AS
                (INSERT INTO MessageThread(isImportant, isSensitive)
                    VALUES (%s, %s) RETURNING id),"""

        for recipient in recipients:
            sql_recipients = """
            forget_""" + str(recipient) + """ AS
                (INSERT INTO CommunicatesWith(threadID, personID, readState)
                    SELECT Thread.id, """ + str(recipient) + """, FALSE
                    FROM Thread),"""
                    
            sql = sql + sql_recipients
            
        msg = """ 
        INSERT INTO Message(threadID, senderID, subject, text, file)
            SELECT Thread.id, %s, %s, %s, %s
            FROM Thread
        """

        sql = sql[:-1] + msg
        
        cur.execute(sql, (False, isSensitive, sender, subject, message, "no file"))
        conn.commit()
        return True
       
def find_user_groups(id):
    cur = conn.cursor()
    sql = """
    WITH user_group(g_id, u_id, name) AS (
        select bundleID, id, name from bundledwith join person
        on personID = person.id
        where person.id = %s
    )

    select b.id, b.admin, b.name,b.is_official from bundle b(id, admin, name, is_official) join user_group
    on b.id = user_group.g_id

    """
    
    cur.execute(sql, (id,))

    groups = cur.fetchall()
    groups = [Group(grp) for grp in groups]  

    cur.close()
    return groups
    

