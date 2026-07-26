import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
from firebase_admin import auth
import random

# IMPORTANT: You need to download your service account JSON file from Firebase Console
# 1. Go to Firebase Console -> Project Settings -> Service Accounts
# 2. Click "Generate New Private Key"
# 3. Save the downloaded JSON file as 'serviceAccountKey.json' in the same folder as this script.
#
# To install the required package, run:
# pip install firebase-admin

def seed_users():
    try:
        cred = credentials.Certificate('serviceAccountKey.json')
        firebase_admin.initialize_app(cred)
    except FileNotFoundError:
        print("Error: 'serviceAccountKey.json' not found!")
        print("Please download the service account key from Firebase Console and place it in this directory.")
        return

    db = firestore.client()

    first_names = ["Ananya", "Aarohi", "Aditi", "Diya", "Isha", "Kavya", "Mira", "Neha", "Pooja", "Riya", "Sneha", "Tara", "Meera", "Zara", "Priya", "Aisha", "Kriti", "Shruti", "Swati", "Sonal", "Nandini", "Kiara", "Radhika", "Bhavya"]
    last_names = ["Sharma", "Verma", "Patel", "Singh", "Kumar", "Gupta", "Deshmukh", "Joshi", "Reddy", "Rao"]

    print("Starting to add 100 users to Firebase Auth and Firestore...")

    success_count = 0
    for i in range(1, 101):
        first = random.choice(first_names)
        last = random.choice(last_names)
        name = f"{first} {last}"
        email = f"{first.lower()}.{last.lower()}{random.randint(10, 999)}@example.com"
        phone = f"+919{random.randint(100000000, 999999999)}"
        password = "Password123!"

        try:
            # 1. Create user in Firebase Auth
            user_record = auth.create_user(
                email=email,
                email_verified=True,
                phone_number=phone,
                password=password,
                display_name=name,
                disabled=False
            )
            
            # 2. Add user to Firestore 'users' collection
            doc_ref = db.collection('users').document(user_record.uid)
            doc_ref.set({
                'name': name,
                'email': email,
                'phone': phone,
                'profilePicUrl': '',
                'createdAt': firestore.SERVER_TIMESTAMP,
                'sosContacts': [],
                'locationSharing': True,
                'role': 'student' # Default role
            })
            success_count += 1
            print(f"[{success_count}/100] Added: {name} | {email}")
            
        except Exception as e:
            print(f"Error adding user {i} ({email}): {e}")

    print(f"\nFinished! Successfully added {success_count} users.")

if __name__ == "__main__":
    seed_users()
