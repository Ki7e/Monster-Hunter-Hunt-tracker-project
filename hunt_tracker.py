print("Welcome to the Hunt Tracker!")

monster = input("What monster are you hunting today? ")

print("Monster:", monster)

weapon = input("What weapon are you using? ")

print("Weapon:", weapon)

hunt_time = 13
hunt_time = hunt_time + 5
while True:
    try:
        carts = int(input("How many times did you cart? "))
        print("Carts:", carts)
        break
    except ValueError:
        print("Please enter a valid whole number.")
