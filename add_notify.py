import sqlite3


def insert_notification(title, body, key, status=0):
    try:
        with sqlite3.connect('login_notification_data.db') as connect:
            cursor = connect.cursor()
            cursor.execute(
                'INSERT INTO notifications (title, body, status, key) VALUES (?, ?, ?, ?)',
                (title, body, status, key)
            )
            connect.commit()
            cursor.close()
            print("Notification inserted successfully.")
    except sqlite3.Error as e:
        print(f"An error occurred: {e}")


def get_user_input():
    title = input('Enter the title: ')
    body = input('Enter the body text: ')
    return title, body


def print_all_data():
    try:
        with sqlite3.connect('login_notification_data.db') as conn:
            cursor = conn.cursor()
            cursor.execute('SELECT * FROM notifications')
            rows = cursor.fetchall()

            # Fetch column names
            column_names = [description[0]
                            for description in cursor.description]

            # Print column names
            print(f"{' | '.join(column_names)}")
            print('-' * len(f"{' | '.join(column_names)}"))

            # Print each row
            for row in rows:
                print(' | '.join(map(str, row)))
    except sqlite3.Error as e:
        print(f"An error occurred: {e}")


def get_all_keys():
    try:
        with sqlite3.connect('login_notification_data.db') as conn:
            cursor = conn.cursor()
            cursor.execute('SELECT key FROM login_key')
            keys = cursor.fetchall()
            return [key[0] for key in keys]
    except sqlite3.Error as e:
        print(f"An error occurred: {e}")
        return []


if __name__ == '__main__':
    title, body = get_user_input()
    keys = get_all_keys()

    if keys:
        for key in keys:
            insert_notification(title, body, key)
    else:
        print("No keys found.")

    print("All data in 'notifications' table:")
    print_all_data()
