import sqlite3

def deleteDataFromLoginKey():
    with sqlite3.connect('login_notification_data.db') as conn:
        cursor = conn.cursor()
        cursor.execute('DELETE FROM login_key')
        conn.commit()


def deleteDataFromNotifications():
    with sqlite3.connect('login_notification_data.db') as conn:
        cursor = conn.cursor()
        cursor.execute('DELETE FROM notifications')
        conn.commit()

def addUser():
    valid_email = 'subodh@svp.com.np'


    key = '42c32c42'

    try:
        with sqlite3.connect('login_notification_data.db') as conn:
            cursor = conn.cursor()

            # Ensure the table exists (optional, if you are certain the table exists, you can skip this)
            cursor.execute('''
            CREATE TABLE IF NOT EXISTS login_key (
                user TEXT NOT NULL,
                key TEXT NOT NULL
            )
            ''')

            cursor.execute(
            'INSERT INTO login_key(user, key) VALUES (?, ?)', (valid_email, key))

            conn.commit()
            print("Record inserted successfully.")

    except sqlite3.Error as e:
        print(f"An error occurred: {e}")


deleteDataFromNotifications()
deleteDataFromLoginKey()
